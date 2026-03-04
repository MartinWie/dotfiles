export const AwakePlugin = async ({ client }) => {
  const procs = new Map()
  const paused = new Map()
  let hooked = false

  const root = async (sessionID) => {
    let id = sessionID
    const seen = new Set()
    for (let i = 0; i < 32; i++) {
      if (seen.has(id)) return undefined
      seen.add(id)
      const result = await client.session.get({ path: { id } }).catch(() => undefined)
      if (!result?.data) return undefined
      if (!result.data.parentID) return result.data.id
      id = result.data.parentID
    }
    return undefined
  }

  const stopRoot = (id) => {
    const proc = procs.get(id)
    if (proc?.exitCode === null) proc.kill()
    procs.delete(id)
  }

  const stopAll = () => {
    for (const id of procs.keys()) stopRoot(id)
    paused.clear()
  }

  const start = async (sessionID) => {
    if (process.platform !== "darwin") return
    const id = await root(sessionID)
    if (!id) return
    const active = procs.get(id)
    if (active?.exitCode === null) return

    const proc = Bun.spawn(["/bin/zsh", "-lc", `exec -a opencode-awake-${id} caffeinate -dimsu -w ${process.pid}`], {
      stdout: "ignore",
      stderr: "ignore",
    })
    procs.set(id, proc)

    if (hooked) return
    hooked = true
    process.once("SIGINT", stopAll)
    process.once("SIGTERM", stopAll)
    process.once("exit", stopAll)
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        const state = event.properties.status.type
        if (state === "busy" || state === "retry") {
          await start(event.properties.sessionID)
        }
        return
      }

      if (event.type === "permission.asked") {
        const id = await root(event.properties.sessionID)
        if (!id) return
        paused.set(event.properties.id, id)
        stopRoot(id)
        return
      }

      if (event.type === "permission.replied") {
        const id = paused.get(event.properties.requestID) || (await root(event.properties.sessionID))
        paused.delete(event.properties.requestID)
        if (!id) return
        if (event.properties.reply === "once" || event.properties.reply === "always") await start(id)
        return
      }

      if (event.type === "session.error") {
        if (!event.properties.sessionID) {
          stopAll()
          return
        }
        const id = await root(event.properties.sessionID)
        if (!id) return
        stopRoot(id)
        return
      }

      if (event.type === "session.idle") {
        const id = await root(event.properties.sessionID)
        if (!id) return
        stopRoot(id)
      }
    },
  }
}
