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

$(function() {
	$('div#nlsources > ul.tabs, div#nlmain > ul.tabs').each(function() {
		osmium_tabify($(this), 0);
	});

	$('div#nlsources > section#search > form > ul.filters, div#nlsources > section#browse > ul.filters, div#nlsources > section#shortlist > ul.filters').each(function() {
		var t = $(this);
		var li, input, a;

		for(var id in osmium_metagroups) {
			li = $(document.createElement('li'));

			input = $(document.createElement('input'));
			input.prop('type', 'hidden');
			input.prop('name', 'mg[' + id + ']');
			input.val('1');
			input.data('metagroupid', id);
			li.append(input);

			a = $(document.createElement('a'));
			a.prop('href', 'javascript:void(0);');
			a.addClass('metagroup');
			a.addClass('mg' + id);
			a.text(osmium_metagroups[id]);
			a.prop('title', 'Filter ' + osmium_metagroups[id] + ' types');
			li.append(a);

			t.append(li);
		}
	}).find('a.metagroup').click(function() {
		var t = $(this).parent().children('input:first-child');
		if(t.val() === '1') {
			t.val('0');
		} else {
			t.val('1');
		}

		$(this).blur();
	});

	$('div#nlsources > section#search > form').submit(function() {
		var t = $(this);
		var ul, li, img, p;

		$.getJSON("../../src/json/search_types.php?" + t.serialize(), function(json) {
			ul = t.parent().children('ul.results');
			ul.empty();
			t.parent().children('p.warning').remove();

			for(var i in json.payload) {
				li = $(document.createElement('li'));
				li.addClass('module');
				li.data('typeid', json.payload[i][0]);
				li.data('category', json.payload[i][2]);
				li.data('subcategory', json.payload[i][3]);
				li.addClass('mg' + json.payload[i][4]);
				li.text(json.payload[i][1]);

				img = $(document.createElement('img'));
				img.prop('alt', '');
				img.prop('src', '//image.eveonline.com/Type/' + json.payload[i][0] + '_64.png');
				li.prepend(img);

				osmium_add_non_shortlist_contextmenu(li);

				ul.append(li);
			}

			if(json.warning !== null) {
				p = $(document.createElement('p'));
				p.addClass('placeholder');
				p.addClass('warning');
				p.html(json.warning);

				ul.after(p);
			}
		});

		return false;
	});

	$('div#nlsources').on('dblclick', 'li.module', function() {
		osmium_add_to_clf($(this));
	});

	$.getJSON('../static-' + osmium_staticver + '/cache/types.json', function(groups) {
		osmium_types = groups.types;

		osmium_init_browser(groups);
		osmium_init_shortlist();
		osmium_init_gen_clf();
	});

	osmium_add_metagroup_style("div#nlsources > section#browse > ", "div#nlsources > section#browse > div.mgroot");
	osmium_add_metagroup_style("div#nlsources > section#shortlist > ", "div#nlsources > section#shortlist > ul");

	osmium_commit_clf();
});

osmium_init_browser = function(groups) {
	var section = $('div#nlsources > section#browse');
	var div, displaymg;

	div = $(document.createElement('div'));
	div.addClass('mgroot');

	var displaymg = function(parent, mg) {
		var ul, li, img, heading;

		if("children" in groups[mg] && groups[mg].children.length > 0) {
			ul = $(document.createElement('ul'));
			ul.addClass('children');

			for(var i in groups[mg].children) {
				li = $(document.createElement('li'));
				li.addClass('uninitialized');
				li.addClass('folded');
				li.data('mgid', groups[mg].children[i]);

				heading = $(document.createElement('h4'));
				heading.text(groups[groups[mg].children[i]].name);

				li.append(heading);
				ul.append(li);
			}

			parent.append(ul);
		}

		if("types" in groups[mg] && groups[mg].types.length > 0) {
			ul = $(document.createElement('ul'));
			ul.addClass('types');

			for(var i in groups[mg].types) {
				var type = osmium_types[groups[mg].types[i]];

				li = $(document.createElement('li'));
				li.addClass('module');
				li.data('typeid', type[0]);
				li.text(type[1]);
				li.data('category', type[2]);
				li.data('subcategory', type[3]);
				li.addClass('mg' + type[4]);

				img = $(document.createElement('img'));
				img.prop('src', '//image.eveonline.com/Type/' + type[0] + '_64.png');
				img.prop('alt', '');
				li.prepend(img);

				osmium_add_non_shortlist_contextmenu(li);

				ul.append(li);
			}

			parent.append(ul);
		}
	};
	displaymg(div, 'root');

	section.children('p.placeholder.loading').remove();
	section.append(div);

	section.on('click', 'li.uninitialized', function() {
		var t = $(this);
		t.removeClass('uninitialized');
		displaymg(t, t.data('mgid'));
	});

	section.on('click', 'li', function(e) {
		var t = $(this);

		t.toggleClass('folded');
		e.stopPropagation();

		if(t.parent().children('li:not(.folded)').length > 0) {
			t.parent().addClass('partiallyunfolded');
		} else {
			t.parent().removeClass('partiallyunfolded');
		}
	});
};

osmium_init_shortlist = function() {
	var ul, li, img, section;

	section = $('div#nlsources > section#shortlist');
	section.children('p.placeholder.loading').remove();

	ul = $(document.createElement('ul'));
	ul.addClass('types');

	for(var i in osmium_shortlist) {
		var type = osmium_types[osmium_shortlist[i]];

		li = $(document.createElement('li'));
		li.addClass('module');
		li.data('typeid', type[0]);
		li.data('category', type[2]);
		li.data('subcategory', type[3]);
		li.addClass('mg' + type[4]);
		li.text(type[1]);

		img = $(document.createElement('img'));
		img.prop('alt', '');
		img.prop('src', '//image.eveonline.com/Type/' + type[0] + '_64.png');
		li.prepend(img);

		osmium_add_shortlist_contextmenu(li, false);

		ul.append(li);
	}

	section.append(ul);
};

osmium_add_metagroup_style = function(aselector, liselector) {
	$(aselector + " ul.filters > li > a.metagroup").click(function() {
		var t = $(this).parent().children('input:first-child');
		var mg = t.data('metagroupid');
		var v = t.val();

		if(v === '1') {
			$('style.mg' + mg).remove();
		} else {
			var style = $(document.createElement('style'));
			style.prop('type', 'text/css');
			style.addClass('mg' + mg);
			style.text(liselector + ' li.module.mg' + mg + ' { display: none; }');
			$('head').append(style);
		}
	});
};

osmium_add_add_to_fit_option = function(source) {
	var li = $(document.createElement('li'));
	var cat = source.data('category');

	if(cat === 'ship') li.text('Use ship');
	else if(cat === 'module') li.text('Fit module');
	else li.text('Add ' + cat);

	li.click(function() {
		osmium_add_to_clf(source);
	});

	return li;
};

osmium_add_non_shortlist_contextmenu = function(li) {
	var span = $(document.createElement('span'));
	span.text('≡');
	span.addClass('contextmenu');

	li.addClass('ctxmenu');
	li.prepend(span);

	var makectxmenu = function(ul, source) {
		var mli;

		ul.append(osmium_add_add_to_fit_option(source));

		mli = $(document.createElement('li'));
		mli.text('Add to shortlist');
		mli.click(function() {
			if($('div#nlsources > section#shortlist > ul.types > li.module').filter(function() {
				return $(this).data('typeid') === source.data('typeid');
			}).length >= 1) {
				return;
			}

			var n = source.clone(true).unbind();
			osmium_add_shortlist_contextmenu(n, true);

			$('div#nlsources > section#shortlist > ul.types').append(n);
			osmium_commit_shortlist();
		});
		ul.append(mli);
	};

	span.click(function(e) {
		osmium_contextmenu(e, makectxmenu, li);
	});
	li.bind('contextmenu', function(e) {
		osmium_contextmenu(e, makectxmenu, li);
		return false;
	});
};

osmium_add_shortlist_contextmenu = function(li, spanexists) {
	var span;

	if(!spanexists) {
		span = $(document.createElement('span'));
		span.text('≡');
		span.addClass('contextmenu');

		li.addClass('ctxmenu');
		li.prepend(span);
	} else {
		span = li.children('span:first-child');
	}
	var makectxmenu = function(ul, source) {
		var mli;

		ul.append(osmium_add_add_to_fit_option(source));

		mli = $(document.createElement('li'));
		mli.text('Remove from shortlist');
		mli.click(function() {
			source.remove();
			osmium_commit_shortlist();
		});
		ul.append(mli);
	};

	span.click(function(e) {
		osmium_contextmenu(e, makectxmenu, li);
	});
	li.bind('contextmenu', function(e) {
		osmium_contextmenu(e, makectxmenu, li);
		return false;
	});

};

osmium_commit_shortlist = function() {
	var opts = {
		token: osmium_token
	};

	$("div#nlsources > section#shortlist > ul.types > li.module").each(function() {
		var t = $(this);
		opts[t.index()] = t.data('typeid');
	});

	$.get("../src/json/shortlist_modules.php", opts);
};

osmium_must_send_clf = false;
osmium_sending_clf = false;
osmium_commit_clf = function() {
	osmium_must_send_clf = true;

	if(osmium_sending_clf) return;
	osmium_sending_clf = true;

	osmium_send_clf();
};

osmium_send_clf = function() {
	if(!osmium_must_send_clf) {
		osmium_sending_clf = false;
		return;
	}
	osmium_must_send_clf = false;

	var postopts = {
		clf: JSON.stringify(osmium_clf)
	};

	var getopts = {
		type: 'new',
		token: osmium_token,
		clftoken: osmium_clftoken
	};

	$.post('../src/json/process_clf.php?' + $.param(getopts), postopts, function(payload) {
		$('div#computed_attributes').html(payload.attributes);

		setTimeout(osmium_send_clf, 500);
	}, 'json');
};

osmium_add_to_clf = function(item) {
	var cat = item.data('category');
	var sub = item.data('subcategory');
	var typeid = item.data('typeid');

	if(cat === 'ship') {
		osmium_clf.ship = { typeid: typeid };
		osmium_gen_ship();
	}

	osmium_commit_clf();
};

osmium_init_gen_clf = function() {
	osmium_gen_ship();
};

osmium_gen_ship = function() {
	var section = $('div#nlattribs > section#ship');
	var img, h, shipname, groupname;

	if("ship" in osmium_clf && "typeid" in osmium_clf.ship) {
		groupname = osmium_types[osmium_clf.ship.typeid][3];
		shipname = osmium_types[osmium_clf.ship.typeid][1];

		img = $(document.createElement('img'));
		img.prop('src', '//image.eveonline.com/Render/' + osmium_clf.ship.typeid + '_256.png');
	} else {
		groupname = '';
		shipname = '(No ship selected)';

		img = $(document.createElement('div'));
		img.addClass('notype');
	}

	h = $(document.createElement('h1'));
	h.append(img);
	h.append($(document.createElement('small')).text(groupname));
	h.append($(document.createElement('strong')).text(shipname));

	section.empty();
	section.append(h);
};
