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

;;; Utilities
(defun site-snippet-file-to-string (&optional filename)
  "Reads a file FILENAME from directory src/_html into a string."
  (with-temp-buffer
    (insert-file-contents (concat base-dir "src/_html/" (or filename "header.html")))
    (buffer-string)))

;;; Extra Packages
(add-to-list 'load-path (concat  base-dir "lisp"))

;;; Default Export Settings
;; They can be overriden on file basis
(setf org-export-with-inlinetasks nil
      org-export-with-section-numbers nil
      org-export-with-smart-quotes t
      org-export-with-statistics-cookies nil
      org-export-with-toc nil
      org-export-with-tasks nil)

;;; Org HTML Setup
(setf org-html-doctype "html5"
      org-html-html5-fancy t
      ;; use styles for HTMLizing
      org-html-htmlize-output-type 'css
      org-html-checkbox-type 'html
      org-html-divs '((preamble "header" "top")
                      (content "main" "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-head-include-default-style t
      org-html-style-default (site-snippet-file-to-string "head-styles.html")
      org-html-head-include-scripts t
      org-html-scripts (site-snippet-file-to-string "head-scripts.html")
      org-html-home/up-format "%s\n%s\n"
)


;;; Publishing Project 

;; #+OPTIONS: auto-id:t toc:t tags:t
;; #+options: html-link-use-abs-url:nil html-postamble:auto
;; #+options: html-preamble:t html-scripts:t html-style:t
;; #+options: html5-fancy:t tex:t
;; #+html_container: div
;; #+description:
;; #+keywords:
;; #+html_head:
;; #+html_head_extra:
;; #+subtitle:
;; #+infojs_opt:
;; #+creator: <a href="https://www.gnu.org/software/emacs/">Emacs</a> 26.1 (<a href="https://orgmode.org">Org</a> mode 9.3.6)
;; #+latex_header:

;; (defun blog-sitemap-function (project &optional sitemap-filename)
;;   "Generates sitemap for the blog"
;;   (let* ((projects-props (cdr project))
;;          (dir (file-name-as-directory (plist-get project-props :base-directory)))
;;          )
;;     (message ))
;;   )

(setf org-publish-project-alist
      `(
        ("homepage" :components ("content" "blog" "assets"))
        ; main content with projects, articles, etc
        ("content"
         :base-directory ,site-source-dir
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,site-publish-dir
         :publishing-function org-html-publish-to-html
         :recursive t          ; descend into sub-folders?
         ;; Content of each file
         :section-numbers nil  ; don't create numbered sections
         :headline-level 4
         :with-author t
         :with-creator nil
         :with-toc t         
         :with-latex t         ; do use MathJax for awesome formulas!
         :htmlized-source t
         
         :html-link-home "/"
         :exclude "^blog"
         
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
         :with-toc nil         ; don't create a table of contents
         :with-latex t         ; do use MathJax for awesome formulas!
         :htmlized-source t

         :html-link-home "/"         
         
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
         :publishing-directory ,(site-publish-dir "/assets")
         :base-extension "*"
         :recursive t
	 :publishing-function org-publish-attachment
         )))
