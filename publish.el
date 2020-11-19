;;; package --- Publishing website evgeniysharapov.com
;;
;;; Commentary:
;;   This is a custom Emacs Lisp script 
;;; Code:

(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-html)
(require 'ox-publish)
(require 'font-lock)

;;; Constants and Variables
;;;; Paths
(defconst base-dir (file-name-directory (or load-file-name (buffer-file-name (current-buffer)))))
(defconst site-publish-dir (concat base-dir "public"))
(defconst site-source-dir (concat base-dir "src"))
(defconst site-assets-dir (concat base-dir "assets"))

;;;; Dates Formatting
(defvar publish-date-format "%h %d, %Y"
  "Format for displaying publish dates.")
(defvar sitemap-date-format "Published %d %b %d %Y"
  "Format dates for the list of blog posts (sitemap).")

;;;; User
(setf user-full-name "Evgeniy N. Sharapov"
      user-mail-address "evgeniy.sharapov@gmail.com")

;;; Extra Packages
(add-to-list 'load-path (concat  base-dir "lisp"))

;;; Utilities
(defun html (filename)
  "Read a file FILENAME from directory src/_html into a string. 
Extension .html is added automatically."
  (with-temp-buffer
    (insert-file-contents (concat base-dir "src/_html/" filename ".html"))
    (buffer-string)))

;;; Org HTML Setup
(setf org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-htmlize-output-type 'css
      org-html-checkbox-type 'html
      org-html-divs '((preamble  "header" "top")
                      (content   "main"   "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format "%Y-%m-%d"
      ;org-html-head-include-default-style t
      ;org-html-style-default (site-snippet-file-to-string "header.html")
      ;org-html-head-include-scripts t
      ;org-html-scripts (site-snippet-file-to-string "scripts.html")
      org-html-home/up-format "%s\n%s\n"
)


;;; Publishing Project 
(setf org-publish-project-alist
      `(
        ("evgeniysharapov.com" :components ("content" "blog" "assets"))
        ; main content with projects, articles, etc
        ("content"
         :base-directory ,site-source-dir
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,site-publish-dir
         :publishing-function org-html-publish-to-html
         :recursive t          ; descend into sub-folders?
         :exclude "^blog"

         ;; Content of each file
         :section-numbers nil  ; don't create numbered sections
         :headline-level 4
         :with-author t
         :with-toc nil         
         :htmlized-source t

         :html-head ,(html "header")
         :html-preamble ,(html "nav")
         :html-postamble ,(html "footer")
         )
        ; blog content has sitemap that is a list of posts
        ("blog"
         :base-directory ,(concat site-source-dir "/blog")
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,(concat site-publish-dir "/blog")
         :publishing-function org-html-publish-to-html
         :recursive t          ; descend into sub-folders?

         ;; Content of each file
         :section-numbers nil  ; don't create numbered sections
         :with-author t
         :with-toc nil         ; don't create a table of contents
         :htmlized-source t

         :html-head ,(html "header-blog")
         :html-preamble ,(html "nav")
         :html-postamble ,(html "footer")
         
         ;; Sitemap
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Blog"
         :sitemap-sort-files anti-chronologically
         ;:sitemap-function blog-sitemap-function
         :sitemap-date-format "Published %d %b %d %Y"
         )
        ; assets, css/js/images/etc
        ("assets"
         :base-directory ,site-assets-dir
         :publishing-directory ,(concat site-publish-dir "/assets")
         :base-extension "css"
         :recursive t
	 :publishing-function org-publish-attachment
         )))
