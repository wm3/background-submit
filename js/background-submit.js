(function() {
	function deferred(fun) {
		var Deff = function() {
			this.success = [];
			this.resolved = null;
		}
		Deff.prototype = {
			then: function(callback) {
				this.success.push(callback);
				if (this.resolved !== null) {
					callback.apply(this, this.resolved);
				}
			},
			resolve: function() {
				var resolved = this.resolved = Array.prototype.slice.call(arguments, 0);
				this.success.forEach(function(s) {
					s.apply(this, resolved);
				});
			},
			and: function(callback) {
				var next = new Deff();
				this.then(function() { callback.call(next, next); });
				return next;
			}
		};
		var deff = new Deff();
		fun.call(deff, deff);
		return deff;
	}

	function up(root) {
		var iframe;
		function saveState() {
			window.location = window.location.toString() + "#upper";
			this.resolve();
		}

		function submit() {
			var self = this;
			var id = 'submit-multipart-'+Math.random();
			iframe = document.createElement('iframe');
			iframe.name = id;
			iframe.style['width'] = '1px';
			iframe.style['height'] = '1px';
			iframe.style['opacity'] = '0';
			iframe.style['position'] = 'absolute';
			iframe.style['border'] = 'none';
			iframe.style['overflow'] = 'none';

			document.body.appendChild(iframe);
			root.target = id;

			iframe.addEventListener('load', function() {
				self.resolve();
			});

			root.submit();
		}

		var adjusted = false;
		function adjustHistory() {
			var self = this;
			var back = function() {
				if (adjusted) return;
				var loc = window.location.toString();
				if (loc.match(/#upper$/)) {
					history.back();
				} else {
					window.removeEventListener('hashchange', back);
					adjusted = true;
					self.resolve();
				}
			}
			window.addEventListener('hashchange', back);
			back();
		}

		function cleanup() {
		}

		deferred(saveState).
		and(submit).
		and(adjustHistory).
		then(cleanup);
	}

	SubmitMultipart = function(root) {
		if (root.jquery) root = root.get(0);
		this.root = root;
	};

	SubmitMultipart.prototype = {
		submit: function() {
			up(this.root);
		}
	}

	SubmitMultipart.activate = function(root) {
		var res = new SubmitMultipart(root);

		return res;
	};

	if (typeof define === 'function' && define.amd) {
		define([], function() { return SubmitMultipart; });
	}
})();
