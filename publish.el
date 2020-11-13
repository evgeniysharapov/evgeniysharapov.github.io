;;; package --- Publishing website evgeniysharapov.com
;;
;;; Commentary:
;;   This is a custom Emacs Lisp script 

(require 'ox-html)
(require 'ox-publish)

;;; Code:
(defconst base-dir (file-name-directory load-file-name))
(defconst site-publish-dir (concat base-dir "/public"))
(defconst site-source-dir (concat base-dir "/src"))

;;; Extra Packages
(add-to-list 'load-path (concat  base-dir "/lisp"))

;;; HTML Styles
;; use styles for HTMLizing
(setq org-html-htmlize-output-type 'css)

;;; Fonts

;; <link href="https://fonts.googleapis.com/css2?family=Montserrat&family=Oswald&display=swap" rel="stylesheet">

;;; Customizations
(defun custom-html-tags (tags info)
  (when tags
    (format "<p class=\"tag\">%s</p>"
	    (mapconcat
	     (lambda (tag)
	       (format "<a href=\"%s\"><span class=\"label\">%s</span></a>"
                       (format  "/projects/tagged/%s/" tag)
		       ;; (concat (plist-get info :html-tag-class-prefix)
		       ;;         (org-html-fix-class-name tag))                       
		       tag))
	     tags ""))))

(defun custom-org-html-format-headline-function
    (todo _todo-type priority text tags info)
  "Custom format function for a headline.
See `org-html-format-headline-function' for details."
  (let ((todo (org-html--todo todo info))
	(priority (org-html--priority priority info))
	(tags (custom-html-tags tags info)))
    (concat todo (and todo " ")
	    priority (and priority " ")
	    text
	    (and tags "&#xa0;&#xa0;&#xa0;") tags)))

(setq org-html-format-headline-function #'custom-org-html-format-headline-function)

(setq org-html-doctype "xhtml5")

;;; Publishing Project 
(setq org-publish-project-alist
      `(
        ("site" :components ("site-content" "site-static"))
        ("site-content"
         :base-directory ,site-source-dir
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,site-publish-dir
         :publishing-function (org-html-publish-to-html)
         :htmlized-source t
         :recursive t          ; descend into sub-folders?
         :section-numbers nil  ; don't create numbered sections
         :with-toc nil         ; don't create a table of contents
         :with-latex t         ; do use MathJax for awesome formulas!
        ; :html-head-extra ""   ; extra <head> entries go here
        ; :html-preamble ""     ; this stuff is put before your post
        ; :html-postamble ""    ; this stuff is put after your post         
         )
        ("site-static"
         :base-directory ,(concat  base-dir "/static")
         :base-extension "*"
         :recursive t
	 :publishing-function (org-publish-attachment)
         )))
