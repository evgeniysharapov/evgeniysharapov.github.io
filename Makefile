#
# Evgeniy Sharapov
# Generate and publish Personal Web-site
#

publish: src/publish.el
	@echo "Publishing"
	emacs --batch --no-init --load src/publish.el --funcall org-publish-all

clean:
	@echo "Cleaning up..."
	@rm -rvf src/*.elc
	@rm -rvf public
