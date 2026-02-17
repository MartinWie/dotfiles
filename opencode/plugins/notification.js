export const NotificationPlugin = async ({ $, client }) => {
  const terminalApp = process.env.TERMINAL_APP || "Ghostty"

  const notify = async (message, sound = "default", focusTerminal = false) => {
    try {
      await $`osascript -e 'display notification "${message}" with title "OpenCode" sound name "${sound}"'`
      if (focusTerminal) {
        await $`osascript -e 'tell application "${terminalApp}" to activate'`
      }
    } catch (e) {
      // ignore errors
    }
  }

  return {
    event: async ({ event }) => {
      // Notify when permission is requested
      if (event.type === "permission.asked") {
        await notify("Permission required!", "Ping", true)
      }
      // Notify when session is done/idle (only for root sessions, not subagents)
      if (event.type === "session.idle") {
        try {
          const result = await client.session.get({ path: { id: event.properties.sessionID } })
          if (result.data?.parentID) return
        } catch (e) {
          // if we can't fetch session info, skip notification to be safe
          return
        }
        await notify("Task completed!", "Glass", true)
      }
      // Notify on errors
      if (event.type === "session.error") {
        await notify("Session error occurred", "Basso", true)
      }
    },
  }
}