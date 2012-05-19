<?php
/* Osmium
 * Copyright (C) 2012 Romain "Artefact2" Dalmaso <artefact2@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Osmium\State;

$__osmium_state =& $_SESSION['__osmium_state'];
$__osmium_login_state = array();

const COOKIE_AUTH_DURATION = 604800; /* 7 days */

function is_logged_in() {
  global $__osmium_state;
  return isset($__osmium_state['a']['character_id']) && $__osmium_state['a']['character_id'] > 0;
}

function do_post_login($account_name, $use_cookie = false) {
  global $__osmium_state;
  $__osmium_state = array();

  \Osmium\Db\query_params('UPDATE osmium.accounts SET last_login_date = $1 WHERE account_name = $2', array(time(), $account_name));

  $q = \Osmium\Db\query_params('SELECT account_id, account_name, key_id, verification_code, creation_date, last_login_date, character_id, character_name, corporation_id, corporation_name, alliance_id, alliance_name FROM osmium.accounts WHERE account_name = $1', array($account_name));
  $__osmium_state['a'] = \Osmium\Db\fetch_assoc($q);

  if($use_cookie) {
    $token = uniqid('Osmium_', true);
    $account_id = $__osmium_state['a']['account_id'];
    $attributes = get_client_attributes();
    $expiration_date = time() + COOKIE_AUTH_DURATION;

    \Osmium\Db\query_params('INSERT INTO osmium.cookie_tokens (token, account_id, client_attributes, expiration_date) VALUES ($1, $2, $3, $4)', array($token, $account_id, $attributes, $expiration_date));

    setcookie('Osmium', $token, $expiration_date, '/', $_SERVER['HTTP_HOST'], false, true);
  }

  $__osmium_state['logout_token'] = uniqid('OsmiumTok_', true);

  check_api_key();
}

function logoff($global = false) {
  global $__osmium_state;
  if($global && !is_logged_in()) return;

  if($global) {
    $account_id = $__osmium_state['a']['account_id'];
    \Osmium\Db\query_params('DELETE FROM osmium.cookie_tokens WHERE account_id = $1', array($account_id));
  }

  setcookie('Osmium', false, 42, '/', $_SERVER['HTTP_HOST'], false, true);
  $_SESSION = array();
}

function get_client_attributes() {
  return hash('sha256', serialize(array($_SERVER['REMOTE_ADDR'],
					$_SERVER['HTTP_USER_AGENT'],
					$_SERVER['HTTP_ACCEPT'],
					$_SERVER['HTTP_HOST']
					)));
}

function check_client_attributes($attributes) {
  return $attributes === get_client_attributes();
}

function print_login_or_logout_box($relative) {
  if(is_logged_in()) {
    print_logoff_box($relative);
  } else {
    print_login_box($relative);
  }
}

function print_login_box($relative) {
  $value = isset($_POST['account_name']) ? "value='".htmlspecialchars($_POST['account_name'], ENT_QUOTES)."' " : '';
  $remember = (isset($_POST['account_name']) && (!isset($_POST['remember']) || $_POST['remember'] !== 'on')) ? '' : "checked='checked' ";
  
  global $__osmium_login_state;
  if(isset($__osmium_login_state['error'])) {
    $error = "<p class='error_box'>\n".$__osmium_login_state['error']."\n</p>\n";
  } else $error = '';

  echo "<div id='state_box' class='login'>\n";
  echo "<form method='post' action='".$_SERVER['REQUEST_URI']."'>\n";
  echo "$error<p>\n<input type='text' name='account_name' placeholder='Account name' $value/>\n";
  echo "<input type='password' name='password' placeholder='Password' />\n";
  echo "<input type='submit' name='__osmium_login' value='Login' /> (<small><input type='checkbox' name='remember' id='remember' $remember/> <label for='remember'>Remember me</label></small>) or <a href='$relative/register'>create an account</a><br />\n";
  echo "</p>\n</form>\n</div>\n";
}

function print_logoff_box($relative) {
  global $__osmium_state;
  $name = $__osmium_state['a']['character_name'];
  $id = $__osmium_state['a']['character_id'];
  $tok = urlencode($__osmium_state['logout_token']);

  echo "<div id='state_box' class='logout'>\n<p>\nLogged in as <img src='http://image.eveonline.com/Character/${id}_32.jpg' alt='' /> <strong>$name</strong>. <a href='$relative/logout?tok=$tok'>Logout</a> (<a href='$relative/logout?tok=$tok'>this session</a> / <a href='$relative/logout?tok=$tok&amp;global=1'>all sessions</a>)\n</p>\n</div>\n";
}

function hash_password($pw) {
  require_once \Osmium\ROOT.'/lib/PasswordHash.php';
  $pwHash = new \PasswordHash(10, true);
  return $pwHash->HashPassword($pw);
}

function check_password($pw, $hash) {
  require_once \Osmium\ROOT.'/lib/PasswordHash.php';
  $pwHash = new \PasswordHash(10, true);
  return $pwHash->CheckPassword($pw, $hash);
}

function try_login() {
  if(is_logged_in()) return;

  $account_name = $_POST['account_name'];
  $pw = $_POST['password'];
  $remember = isset($_POST['remember']) && $_POST['remember'] === 'on';

  list($hash) = \Osmium\Db\fetch_row(\Osmium\Db\query_params('SELECT password_hash FROM osmium.accounts WHERE account_name = $1', array($account_name)));

  if(check_password($pw, $hash)) {
    do_post_login($account_name, $remember);
  } else {
    global $__osmium_login_state;
    $__osmium_login_state['error'] = 'Invalid credentials. Please check your account name and password.';
  }
}

function try_recover() {
  if(is_logged_in()) return;

  if(!isset($_COOKIE['Osmium']) || empty($_COOKIE['Osmium'])) return;
  $token = $_COOKIE['Osmium'];
  $now = time();
  $login = false;

  list($has_token) = pg_fetch_row(\Osmium\Db\query_params('SELECT COUNT(token) FROM osmium.cookie_tokens WHERE token = $1 AND expiration_date >= $2', array($token, $now)));

  if($has_token == 1) {
    list($account_id, $client_attributes) = pg_fetch_row(\Osmium\Db\query_params('SELECT account_id, client_attributes FROM osmium.cookie_tokens WHERE token = $1', array($token)));

    if(check_client_attributes($client_attributes)) {
      $k = pg_fetch_row(\Osmium\Db\query_params('SELECT account_name FROM osmium.accounts WHERE account_id = $1', array($account_id)));
      if($k !== false) {
	list($name) = $k;
	do_post_login($name, true);
	$login = true;
      }
    }

    \Osmium\Db\query_params('DELETE FROM osmium.cookie_tokens WHERE token = $1', array($token));
  }

  if(!$login) {
    logoff(false); /* Delete that erroneous cookie */
  }
}

function check_api_key() {
  if(!is_logged_in()) return;
  global $__osmium_state;

  $key_id = $__osmium_state['a']['key_id'];
  $v_code = $__osmium_state['a']['verification_code'];
  $info = \Osmium\EveApi\fetch('/account/APIKeyInfo.xml.aspx', array('keyID' => $key_id, 'vCode' => $v_code));

  if(!($info instanceof \SimpleXMLElement)) {
    global $__osmium_login_state;

    logoff(false);
    $__osmium_login_state['error'] = 'Login failed because of API issues (osmium_api() returned a non-object). Sorry for the inconvenience.';
    return;
  }

  if(isset($info->error) && !empty($info->error)) {
    $err_code = (int)$info->error['code'];
    /* Error code details: http://wiki.eve-id.net/APIv2_Eve_ErrorList_XML */
    if(200 <= $err_code && $err_code < 300) {
      /* Most likely user error */
      $__osmium_state['renew_api'] = true;
    } else {
      /* Most likely internal error */
      global $__osmium_login_state;

      logoff(false);
      $__osmium_login_state['error'] = 'Login failed because of API issues (got error '.$err_code.': '.((string)$info->error).'). Sorry for the inconvenience.';
      return;  
    }
  }
}

function api_maybe_redirect($relative) {
  global $__osmium_state;
  global $__osmium_state_renew_api_ignore;

  if(!is_logged_in()) return;

  if(isset($__osmium_state['renew_api']) && $__osmium_state['renew_api'] === true
     && !$__osmium_state_renew_api_ignore) {
    header('Location: '.$relative.'/renew_api?non_consensual=1', true, 303);
    die();
  }
}

function get_setting($key, $default = null) {
  if(!is_logged_in()) return $default;

  global $__osmium_state;
  $accountid = $__osmium_state['a']['account_id'];
  $ret = $default;

  $k = \Osmium\Db\query_params('SELECT value FROM osmium.account_settings WHERE account_id = $1 AND key = $2', array($accountid, $key));
  while($r = \Osmium\Db\fetch_row($k)) {
    $ret = $r[0];
  }

  return $ret;
}

function put_setting($key, $value) {
  if(!is_logged_in()) return;

  global $__osmium_state;
  $accountid = $__osmium_state['a']['account_id'];
  \Osmium\Db\query_params('DELETE FROM osmium.account_settings WHERE account_id = $1 AND key = $2', array($accountid, $key));
  \Osmium\Db\query_params('INSERT INTO osmium.account_settings (account_id, key, value) VALUES ($1, $2, $3)', array($accountid, $key, $value));
}

function get_token() {
  global $__osmium_state;
  return $__osmium_state['logout_token'];
}