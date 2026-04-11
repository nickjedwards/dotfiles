import Gtk from 'gi://Gtk?version=4.0'

export default function Calendar() {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={16}>
      <label label="Calendar" halign={Gtk.Align.START} />
      <Gtk.Calendar />
    </box>
  )
}
