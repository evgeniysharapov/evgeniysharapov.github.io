#
# Evgeniy Sharapov
# Generate and publish Personal Web-site
#

publish: publish.el
	@echo "Publishing"
	emacs --batch --no-init --load publish.el --funcall org-publish-all

clean:
	@echo "Cleaning up..."
	@rm -rvf *.elc
	@rm -rvf public
