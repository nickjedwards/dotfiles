import { createComputed } from 'ags'
import { execAsync } from 'ags/process'
import { createPoll } from 'ags/time'

function update() {
  execAsync(`ghostty -e paru`)
    .then(() => void 0)
    .catch((error) => console.error('pacman:', error))
}

export default function Pacman() {
  const updates = createPoll('0', 3000, `bash -c "(checkupdates ; paru -Qua) | wc -l"`)

  const classes = createComputed(() => (updates() === '0' ? 'none' : 'cherry'))
  const label = createComputed(() => (updates() === '0' ? '󰇘' : ''))

  return (
    <box class="pacman">
      <button onClicked={update} tooltipText={updates.as((count) => `${count} updates`)}>
        <box spacing={7}>
          <label class="pac-man" label="󰮯" />
          <label class={classes} label={label} />
        </box>
      </button>
    </box>
  )
}
