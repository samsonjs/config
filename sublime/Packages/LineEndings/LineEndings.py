import sublime, sublime_plugin

s = sublime.load_settings('LineEndings.sublime-settings')
class Pref:
	def load(self):
		Pref.show_line_endings_on_status_bar          = s.get('show_line_endings_on_status_bar', True)
		Pref.alert_when_line_ending_is                = s.get('alert_when_line_ending_is', [])
		Pref.auto_convert_line_endings_to             = s.get('auto_convert_line_endings_to', '')

Pref = Pref()
Pref.load()
s.add_on_change('reload', lambda:Pref.load())

class StatusBarLineEndings(sublime_plugin.EventListener):

	def on_load(self, view):
		if view.line_endings() in Pref.alert_when_line_ending_is:
			sublime.message_dialog(u''+view.line_endings()+' line endings detected on file:\n\n'+view.file_name());
		if Pref.auto_convert_line_endings_to != '' and view.line_endings() != Pref.auto_convert_line_endings_to:
			view.run_command('set_line_ending', {"type":Pref.auto_convert_line_endings_to})
		if Pref.show_line_endings_on_status_bar:
			self.show(view)

	def on_activated(self, view):
		if Pref.show_line_endings_on_status_bar:
			self.show(view)

	def on_post_save(self, view):
		if Pref.show_line_endings_on_status_bar:
			self.show(view)

	def show(self, view):
		if view is not None:
			if view.is_loading():
				sublime.set_timeout(lambda:self.show(view), 100)
			else:
				view.set_status('line_endings', view.line_endings())
				sublime.set_timeout(lambda:view.set_status('line_endings', view.line_endings()), 400)

class SetLineEndingWindowCommand(sublime_plugin.TextCommand):

	def run(self, view, type):
		active_view = sublime.active_window().active_view()
		for view in sublime.active_window().views():
			sublime.active_window().focus_view(view);
			view.run_command('set_line_ending', {"type":type})
			view.set_status('line_endings', view.line_endings())
		sublime.active_window().focus_view(active_view);

	def is_enabled(self):
		return len(sublime.active_window().views()) > 0

class ConvertIndentationWindowCommand(sublime_plugin.TextCommand):

	def run(self, view, type):
		active_view = sublime.active_window().active_view()
		for view in sublime.active_window().views():
			sublime.active_window().focus_view(view);
			if type == 'spaces':
				view.run_command('expand_tabs', {"set_translate_tabs":True})
			else:
				view.run_command('unexpand_tabs', {"set_translate_tabs":True})
		sublime.active_window().focus_view(active_view);


	def is_enabled(self):
		return len(sublime.active_window().views()) > 0
