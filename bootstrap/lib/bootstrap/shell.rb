# frozen_string_literal: true

require "open3"

module Bootstrap
  # Running things and talking to the person. Prompts read from the terminal
  # directly so `bash -c "$(curl …)"` and a piped stdin both work.
  module Shell
    module_function

    def say(message) = puts(message)

    def heading(title) = puts("\n== #{title}")

    def run(*command, chdir: nil, quiet: false)
      say("$ #{command.join(" ")}") unless quiet
      options = chdir ? {chdir:} : {}
      raise Error, "failed: #{command.join(" ")}" unless system(*command, **options)
    end

    # Non-fatal: the caller decides what a failure means.
    def try(*command, chdir: nil)
      options = chdir ? {chdir:} : {}
      system(*command, **options, out: File::NULL, err: File::NULL)
    end

    def capture(*command, chdir: nil)
      options = chdir ? {chdir:} : {}
      out, status = Open3.capture2(*command, **options)
      raise Error, "failed: #{command.join(" ")}" unless status.success?

      out.chomp
    end

    def exists?(command) = system("command", "-v", command, out: File::NULL, err: File::NULL)

    def tty
      @tty ||= File.open("/dev/tty", "r+")
    rescue SystemCallError
      @tty = $stdin
    end

    def ask(prompt)
      tty.print("#{prompt} ")
      tty.flush if tty.respond_to?(:flush)
      tty.gets.to_s.strip
    end

    def pause(message)
      say(message)
      ask("Press enter when done.")
    end

    def yes?(prompt) = ask("#{prompt} [y/N]").match?(/\Ay/i)
  end
end
