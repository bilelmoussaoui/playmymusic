/*-
 * Copyright (c) 2017-2017 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace PlayMyMusic.Widgets {
    public class Radio : Gtk.ListBoxRow {
        PlayMyMusic.Services.LibraryManager library_manager;

        public PlayMyMusic.Objects.Radio radio { get; private set; }
        public string title { get { return radio.title; } }

        Gtk.Image cover;
        Gtk.Menu menu;

        construct {
            library_manager = PlayMyMusic.Services.LibraryManager.instance;
        }

        public Radio (PlayMyMusic.Objects.Radio radio) {
            this.radio = radio;
            this.radio.cover_changed.connect (() => {
                cover.pixbuf = this.radio.cover;
            });
            this.radio.removed.connect (() => {
                this.destroy ();
            });
            build_ui ();
        }

        private void build_ui () {
            var event_box = new Gtk.EventBox ();
            event_box.button_press_event.connect (show_context_menu);

            var content = new Gtk.Grid ();
            content.margin = 12;
            content.column_spacing = 12;
            event_box.add (content);

            cover = new Gtk.Image ();
            cover.get_style_context ().add_class ("card");
            if (this.radio.cover == null) {
                cover.set_from_icon_name ("network-cellular-connected-symbolic", Gtk.IconSize.DIALOG);
            } else {
                cover.pixbuf = this.radio.cover;
            }
            content.attach (cover, 0, 0, 1, 2);

            var title = new Gtk.Label (("<b>%s</b>").printf(radio.title));
            title.use_markup = true;
            title.halign = Gtk.Align.START;
            content.attach (title, 1, 0);

            var url = new Gtk.Label (("<small>%s</small>").printf(radio.url));
            url.use_markup = true;
            url.halign = Gtk.Align.START;
            content.attach (url, 1, 1);

            menu = new Gtk.Menu ();
            var menu_copy = new Gtk.MenuItem.with_label (_("Remove Radio Station"));
            menu_copy.activate.connect (() => {
                library_manager.remove_radio_station (this.radio);
            });

            menu.append (menu_copy);
            menu.show_all ();

            this.add (event_box);
        }

        private bool show_context_menu (Gtk.Widget sender, Gdk.EventButton evt) {
            if (evt.type == Gdk.EventType.BUTTON_PRESS && evt.button == 3) {
                menu.popup (null, null, null, evt.button, evt.time);
                return true;
            }
            return false;
        }
    }
}
