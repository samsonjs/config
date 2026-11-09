---
name: shared-machine
description: Rules for background processes, log captures, simulators, stress tests and heavy parallel builds on a computer shared with other sessions. Load before starting any of these.
---

## Background processes and shared-machine resources

This is my working computer, shared with other sessions. Keeping it responsive and cleaning up
what you start are part of completing the task.

- **Bound temporary diagnostics before starting them.** Log captures, profilers, watchers and
  load generators need a finite runtime and an output-size limit. Prefer a supervised foreground
  process. `nohup`, `disown` and `&` are not lifecycle management: a detached diagnostic must have
  an independent deadline that still stops it if the launching shell or agent disappears.
- **Own the processes you start.** Record their PID or dedicated process group, start time,
  command, purpose and output paths immediately. Arrange cleanup on success, failure and
  cancellation, including child processes. Before declaring the task finished, stop temporary
  processes and verify they exited. Check identity before signalling a saved PID, since PIDs
  can be reused. Never use blanket `pkill` or `killall` by executable name: another session may
  own a matching process.
- **Shut down the simulators you boot, and delete the ones you create.** A booted iOS simulator
  runs a full copy of the OS (~300 processes, several GB) and nothing stops it until someone does.
  Whenever you boot one, `xcrun simctl shutdown` it when the task is finished or you no longer
  need it, not at the end of the session. If you created a simulator for the task (`simctl
  create`, a per-task name like `foo-proof`), `xcrun simctl delete` it too. Note the UDID of each
  one you boot or create when you do it, because later you can't tell from `simctl list` which
  were yours. Only touch ones you booted yourself: `xcodebuild` and other sessions boot devices
  too, and one that was already running when you started belongs to someone else. Say in your
  final message which simulators you shut down or deleted and which you left running.
- **Keep captures narrow and watch their cost.** Filter device/system logs at the source to the
  process or subsystem needed; avoid an unbounded whole-device capture for one app's test.
  Cap or rotate output and check memory, CPU and file growth during longer runs. Stop your own
  diagnostic when its budget is exceeded or its purpose is complete. Writing logs to disk does
  not prove the logger's memory use is bounded.
- **Ask before artificial stress.** Reproducing a flaky test does not authorize CPU burners
  such as `yes`, memory pressure generators or disk/network saturation. Agree on concurrency,
  resource limits and a short duration first. One CPU burner per core can still saturate the
  entire machine. Apply the same owned-process cleanup and independent deadline.
- **Budget parallel heavy work across sessions.** Do not assume all cores, RAM, simulators or
  build workers are yours. Coordinate or serialize expensive builds/tests when the machine is
  under pressure; do not add load to an already saturated machine without agreement.
- **Persistent work needs an explicit handoff.** Leave a service, monitor or capture running
  after the task only when I requested that continuing work, or another named session accepts
  ownership within the authorized task. Record its owner, stop mechanism and agreed lifetime;
  a finite observation window must stop automatically. Report what remains running and why.
