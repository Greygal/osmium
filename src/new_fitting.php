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

namespace Osmium\Page\NewFitting;

require __DIR__.'/../inc/root.php';
require __DIR__.'/../inc/ajax_common.php';

const FINAL_STEP = 5;

if(!\Osmium\State\is_logged_in()) {
  \Osmium\fatal(403, 'Sorry, anonymous users cannot create fittings. Please login first and retry.');
}

\Osmium\Chrome\print_header('Create a new fitting', '.');;
echo "<script>\nvar osmium_tok = '".\Osmium\State\get_token()."';\n";
echo "var osmium_slottypes = ".json_encode(\Osmium\Fit\get_slottypes()).";\n</script>\n";

if(!isset($_SESSION['__osmium_create_fit_step'])) {
  $_SESSION['__osmium_create_fit_step'] = 1;
}

$step =& $_SESSION['__osmium_create_fit_step'];

$steps = array(
	       1 => 'ship_select',
	       2 => 'modules_select',
	       3 => 'charges_select',
	       4 => 'drones_select',
	       5 => 'final_settings',
);

if(isset($_POST['prev_step'])) {
  if(call_user_func(__NAMESPACE__.'\\'.$steps[$step].'_pre')) --$step;
} else if(isset($_POST['next_step'])) {
  if(call_user_func(__NAMESPACE__.'\\'.$steps[$step].'_post')) ++$step;
} else if(isset($_POST['finalize'])) {
  if(call_user_func(__NAMESPACE__.'\\'.$steps[FINAL_STEP].'_post')) finalize();
}

if($step < 1) $step = 1;
if($step > FINAL_STEP) $step = FINAL_STEP;

call_user_func(__NAMESPACE__.'\\'.$steps[$step]);

\Osmium\Chrome\print_footer();

/* ----------------------------------------------------- */

function print_form_prevnext() {
  global $step;

  $prevd = $step == 1 ? "disabled='disabled' " : '';

  if($step == FINAL_STEP) {
    $next = "<input type='submit' name='finalize' value='Finalize fitting' class='final_step' />";
  } else {
    $next = "<input type='submit' name='next_step' value='Next step &gt;' class='next_step' />";
  }

  echo "<tr>\n<td></td>\n<td>\n";
  echo "<div style='float: right;'>$next</div>\n";
  echo "<input type='submit' name='prev_step' value='&lt; Previous step' class='prev_step' $prevd/>\n";
  echo "</td>\n</tr>\n";
}

function print_h1($name) {
  global $step;
  echo "<h1>New fitting, step $step of ".FINAL_STEP.": $name</h1>\n";
}

/* ----------------------------------------------------- */

function ship_select() {
  $fit =& \Osmium\Fit\get_fit();

  print_h1('select ship hull');
  \Osmium\Forms\print_form_begin();

  $q = \Osmium\Db\query_params('SELECT typeid, typename, groupname FROM osmium.invships ORDER BY groupname ASC, typename ASC', array());
  $o = array();
  while($row = \Osmium\Db\fetch_row($q)) {
    $o[$row[2]][$row[0]] = $row[1];
  }

  if(isset($fit['hull']['typeid'])) $_POST['hullid'] = $fit['hull']['typeid'];
  \Osmium\Forms\print_select('', 'hullid', $o, 16, null, 
			     \Osmium\Forms\HAS_OPTGROUPS | \Osmium\Forms\FIELD_REMEMBER_VALUE);

  print_form_prevnext();
  \Osmium\Forms\print_form_end();
}

function ship_select_pre() { /* Unreachable code for the 1st step */ };
function ship_select_post() {
  if(!\Osmium\Fit\init_fit($_POST['hullid'])) {
    \Osmium\Forms\add_field_error('hullid', "You sent an invalid typeid.");
    return false;
  }

  return true;
};

/* ----------------------------------------------------- */

function print_modules_searchbox() {
  echo "<div id='searchbox'>\n<h2 class='has_spinner'>Search modules";
  echo "<img src='./static/icons/spinner.gif' id='searchbox_spinner' class='spinner' alt='' /><br />\n";
  echo "<em class='help'>(Double-click to fit)</em>\n</h2>\n";
  echo "<form action='".$_SERVER['REQUEST_URI']."' method='get'>\n";
  echo "<input type='text' placeholder='Search modules...' />\n";
  echo "<input type='submit' value='Search' />\n<br />\n";
  $filters = unserialize(\Osmium\State\get_setting('module_search_filter', serialize(array())));
  $filters = array_combine($v = array_values($filters), $v);
  $req = \Osmium\Db\query_params('SELECT metagroupname, metagroupid FROM osmium.invmetagroups ORDER BY metagroupname ASC', array());
  echo "<p id='search_filters'>\nFilter modules: ";
  while($row = \Osmium\Db\fetch_row($req)) {
    list($name, $id) = $row;
    if(isset($filters[$id])) {
      $nods = ' style="display:none;"';
      $ds = '';
    } else {
      $ds = ' style="display:none;"';
      $nods = '';
    }

    echo "<img src='./static/icons/metagroup_$id.png' alt='Show $name modules' title='Show $name modules' class='meta_filter' id='meta_filter_$id' data-metagroupid='$id' data-toggle='meta_filter_{$id}_disabled' data-filterval='0' $nods/>";
    echo "<img src='./static/icons/metagroup_{$id}_ds.png' alt='Hide $name modules' title='Hide $name modules' class='meta_filter ds' id='meta_filter_{$id}_disabled' data-metagroupid='$id' data-toggle='meta_filter_$id' data-filterval='1' $ds/>\n";
  }

  echo "</p>\n</form>\n<ul id='search_results'></ul>\n</div>\n";

  foreach($filters as &$val) $val = "$val: 0";
  echo "<script>var search_params = {".implode(',', $filters)."};</script>\n";
}

function print_modulelist() {
  echo "<div id='loadoutbox'>\n<h2 class='has_spinner'>Loadout";
  echo "<img src='./static/icons/spinner.gif' id='loadoutbox_spinner' class='spinner' alt='' /><br />\n";
  echo "<em class='help'>(Double-click to remove)</em>\n</h2>\n";
  
  $fit = \Osmium\Fit\get_fit();
  $categories = array();
  foreach(\Osmium\Fit\get_slottypes() as $type) {
    $categories[$type] = ucfirst($type);
  }

  echo "<table id='slot_count'>\n<tr>\n";
  foreach($categories as $type => $fname) {
    echo "<th><img src='./static/icons/slot_$type.png' alt='$fname slots' title='$fname slots' /> <strong id='{$type}_count'></strong></th>\n";
  }
  echo "</tr>\n</table>\n";

  foreach($categories as $type => $fname) {
    echo "<div id='{$type}_slots' class='loadout_slot_cat'>\n<h3>$fname slots</h3>";
    echo "<ul></ul>\n";
    echo "</div>\n";
  }
  \Osmium\Forms\print_form_begin();
  print_form_prevnext();
  \Osmium\Forms\print_form_end();
  echo "</div>\n";
}

function print_modules_shortlist() {
  echo "<div id='shortlistbox'>\n<h2 class='has_spinner'>Shortlist";
  echo "<img src='./static/icons/spinner.gif' id='shortlistbox_spinner' class='spinner' alt='' /><br />\n";
  echo "<em class='help'>(Double-click to fit)</em>\n</h2>\n";
  echo "<ul id='modules_shortlist'>\n";
  echo "</ul>\n</div>\n";
}

function modules_select() {
  print_h1('select modules');

  print_modules_searchbox();
  print_modules_shortlist();
  print_modulelist();
  \Osmium\Chrome\print_js_snippet('new_fitting');
  echo "<script>\n$(function() {\n";
  echo "osmium_shortlist_load(".json_encode(\Osmium\AjaxCommon\get_module_shortlist()).");\n";
  echo "osmium_loadout_load(".json_encode(\Osmium\Fit\get_fit()).");\n";
  echo "});\n</script>\n";
}

function modules_select_pre() { return true; };
function modules_select_post() { return true; };

/* ----------------------------------------------------- */

function print_charge_presetsbox() {
  echo "<div id='presetsbox'>\n<h2 class='has_spinner'>Presets ";
  echo "<a href='javascript:void(0);' id='new_preset'><img src='./static/icons/add.png' alt='Create a new preset' title='New preset' /></a>";
  echo "<img src='./static/icons/spinner.gif' id='presetsbox_spinner' class='spinner' alt='' /><br />\n";
  echo "<em class='help'>(Click to change active preset)</em></h2>\n";
  echo "<ul id='presets'>\n";
  echo "</ul>\n";
  echo "</div>\n";
}

function print_charge_groups() {
  echo "<div id='chargegroupsbox'>\n<h2 class='has_spinner'>Charge groups";
  echo "<img src='./static/icons/spinner.gif' id='chargegroupsbox_spinner' class='spinner' alt='' /><br />\n";
  echo "<em class='help'>(Select multiple items by dragging or using Ctrl)</em>\n</h2>\n";
  
  \Osmium\Forms\print_form_begin();
  echo "<tr><td colspan='2'>\n<ul id='chargegroups'>\n";

  foreach(get_charges() as $i => $charges) {
    echo "<li id='group_$i'>\n";
    print_chargegroup($i, $charges['typeids'], $charges['charges']);
    echo "</li>\n";
  }

  echo "</ul>\n</td></tr>\n";
  print_form_prevnext();
  \Osmium\Forms\print_form_end();
  echo "</div>\n";
}

function get_charges() {
  $fit =& \Osmium\Fit\get_fit();
  $typeids = array();
  foreach($fit['modules'] as $type => $a) {
    foreach($a as $k) {
      if(is_array($k)) {
	$typeids[$k['typeid']] = true;
      }
    }
  }

  $groups = array();
  $typetogroups = array();
  $keystonumbers = array();
  $z = 0;

  foreach($typeids as $typeid => $val) {
    $chargeids = array();
    $req = \Osmium\Db\query_params('SELECT chargeid, chargename FROM osmium.invcharges WHERE moduleid = $1 ORDER BY chargename ASC', array($typeid));
    while($row = \Osmium\Db\fetch_row($req)) {
      $chargeids[$row[0]] = array('typeid' => $row[0], 'typename' => $row[1]);
    }

    if(count($chargeids) == 0) continue;

    $keys = array_keys($chargeids);
    sort($keys);
    $key = implode(' ', $keys);
    if(!isset($keystonumbers[$key])) {
      $keystonumbers[$key] = $z;
      $groups[$z] = array_values($chargeids);
      ++$z;
    }
      $typetogroups[$typeid] = $keystonumbers[$key];
  }

  $result = array();
  foreach($typetogroups as $typeid => $i) {
    $result[$i]['typeids'][] = $typeid;
  }
  foreach($groups as $i => $group) {
    $result[$i]['charges'] = $group;
  }

  return $result;
}

function print_chargegroup($groupid, $typeids, $charges) {
  $fit =& \Osmium\Fit\get_fit();
  echo "<ul class='chargegroup'>\n";
  foreach($fit['modules'] as $type => $a) {
    foreach($a as $i => $module) {
      $id = $module['typeid'];
      if(!in_array($id, $typeids)) continue;

      $name = $module['typename'];
      echo "<li id='{$type}_$i'><img src='http://image.eveonline.com/Type/{$id}_32.png' alt='$name' title='$name' class='module_icon' />";
      echo "<img src='./static/icons/no_charge.png' alt='(No charge)' title='(No charge)' class='charge_icon' />\n";
      echo "<select name='charge_{$groupid}_$i' data-slottype='$type'>\n";
      echo "<option value='-1'>(No charge)</option>\n";
      foreach($charges as $charge) {
	echo "<option value='".$charge['typeid']."'>".$charge['typename']."</option>\n";
      }
      echo "</select>\n";
      echo "</li>\n";
    }
  }
  echo "</ul>\n";
}

function charges_select() {
  print_h1('select charges');
  
  print_charge_presetsbox();
  print_charge_groups();

  $fit =& \Osmium\Fit\get_fit();
  echo "<script>\nvar charge_presets = ".json_encode($fit['charges']).";\nvar selected_preset = 0;\n</script>\n";

  \Osmium\Chrome\print_js_snippet('new_fitting_charges');
}

function charges_select_pre() { return true; };
function charges_select_post() { return true; };

/* ----------------------------------------------------- */

function drones_select() {
  print_h1('select drones');

  \Osmium\Forms\print_form_begin();
  print_form_prevnext();
  \Osmium\Forms\print_form_end();
}

function drones_select_pre() { return true; };
function drones_select_post() { return true; };

/* ----------------------------------------------------- */

function final_settings() {
  print_h1('final adjustments');

  \Osmium\Forms\print_form_begin();
  print_form_prevnext();
  \Osmium\Forms\print_form_end();
}

function final_settings_pre() { return true; };
function final_settings_post() { return true; };

/* ----------------------------------------------------- */

function finalize() {

}