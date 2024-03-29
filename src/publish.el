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
;;; Correct for newer Emacs Version
(if (not (featurep 'cl-lib))
    (progn
      (require 'cl)
      ;; fix conflict name
      (defalias 'cl-reduce 'reduce))
  (require 'cl-lib))


;;; Utilities
(defun parent-directory (path)
  "Return parent directory of PATH whether it's a file or a directory."
  (file-name-directory (directory-file-name path)))

(defun filename (&rest paths)
  "Make a file path out of PATHS."
  (let ((dir (cl-reduce #'concat (mapcar (lambda (path) (file-name-as-directory path)) (butlast paths)))))
    (concat (file-name-as-directory dir) (car (last paths)))))

(defun listify (s)
  "Convert string S into a list of strings."
  (if (stringp s)
      (split-string s "[ ,;]+" 'omit-nulls "trim")
    s))

(defun tagify (s)
  "Convert given string S into a string that represents Org tags.
So the S is split into parts and then joined into a string with ':' character."
  (let ((tags (listify s)))
    (if tags (concat ":" (mapconcat 'identity tags ":") ":")
      "")))

;;; Constants and Variables
;;;; Paths
(defconst *source-dir* (file-name-directory (or load-file-name (buffer-file-name (current-buffer)))))
(defconst *base-dir* (parent-directory *source-dir*))
(defconst *site-output-dir* (filename *base-dir* "output"))
(defconst *site-content-dir* (filename *base-dir* "content"))
(defconst *site-publish-dir* (filename *base-dir* "public"))
(defconst *site-assets-dir* (filename *base-dir* "assets"))

;;;; Dates Formatting
(defvar publish-date-format "%h %d, %Y"
  "Format for displaying publish dates.")
(defvar sitemap-date-format "Published %d %b %d %Y"
  "Format dates for the list of blog posts (sitemap).")
(defvar blog-index-date-format "%b %e, %Y"
  "Format dates for list of published blog posts.")

;;;; User
(setf user-full-name "Evgeniy N. Sharapov"
      user-mail-address "evgeniy.sharapov@gmail.com")

;;; Extra Packages
(add-to-list 'load-path (filename *source-dir* "lisp"))

;;; Org HTML Setup
(setf org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-htmlize-output-type 'css
      org-html-divs '((preamble  "header" "top")
                      (content   "main"   "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-head-include-default-style nil
      org-html-head-include-scripts nil)

(defun html (filename)
  "Read a file FILENAME from directory src/_html into a string.
Extension .html is added automatically."
  (let ((html-dir (filename *site-content-dir* "_html")))
    (with-temp-buffer
      (make-directory html-dir t)
      (insert-file-contents (filename html-dir (concat filename ".html")))
      (buffer-string))))

;;; Tags page build up
(defun add-tags-pages (tags file &optional headline)
  "Generates org files with tags, reusing existing org files for tags if they are existing.
TAGS is a list of tags. FILE is a filename. HEADLINE is an optional headline.
0. iterate over tags list and for each tag 
1. check if file exists
2. if exists add more entries to the file
3. if doesn't exist then create a new file and add the entries"
  (mapc (lambda (tag)
          (let* ((tags-directory  (filename *site-output-dir* "tags"))
                 (r (make-directory tags-directory t))
                 (tagfile (filename tags-directory (concat tag ".org")))
                 (entry (if headline
                            (format  "[[file:%s][%s]]\n" file headline)
                          (format "[[file:%s]]\n" file))))
            (with-temp-buffer
              ;; content to write
              (insert entry)
              ;; will write to a new file or append to existing one
              (if (file-exists-p tagfile)                  
                  (write-region (point-min) (point-max) tagfile)
                (with-temp-file tagfile entry)))))
        tags))

(defun tags-to-links (orig-fun &rest args)
  "This is an advice for `org-html--tags' function that turns tags into links.
That is anchor tags pointing to /tags/name page"
  (let* ((tags (car args))
         (info (cadr args))
         (tags-links (mapcar (lambda (tag) (format "<a href='/tags/%s.html'>%s</a>" tag tag)) tags))
         (new-args (list tags-links info)))
    (apply orig-fun new-args)))

(advice-add #'org-html--tags :around #'tags-to-links)

;;; Customizing Publishing Process
(defun  blog-sitemap-function (title list)
  "This is a replacement for `org-publish-sitemap-default'.
Arguments TITLE and LIST are exactly the same"
  (mapconcat
   'identity
   (list
    (concat "#+TITLE: " title)
    ;; 9.3 sort of broke API
    (if (version< org-version "9.3")
        (org-list-to-subtree list '(:istart "** "))
      (org-list-to-subtree list nil '(:istart "** ")))
    "
#+OPTIONS: title:nil num:nil tags:t")
   "\n\n"))

(defun blog-sitemap-format-entry (entry style project)
  "Format each entry in blog index.
Same parameters ENTRY, STYLE and PROJECT as in `org-publish-sitemap-default-entry'."
  (when (not (directory-name-p entry))
    (let* ((kw (org-publish-find-property entry :keywords project 'html))
           (file (filename (org-publish-property :base-directory project) entry))
           (title (org-publish-find-title entry project)))
      ;; this will create tags
      (add-tags-pages (listify kw) file title)
      ;; this will be returned to sitemap
      (concat
       (format "
[[file:%s][%s]]\t\t%s
#+begin_article-info
#+begin_date
%s
#+end_date
#+end_article-info
#+INCLUDE: \"%s::#preview\"  :only-contents t

[[file:%s][Read more...]]
"
               entry
               title
               (tagify (or kw ""))
               (format-time-string blog-index-date-format (org-publish-find-date entry project))
               entry
               entry)))))

(defun sass-compile-publish (_plist filename pub-dir)
  "Publish an scss/sass file.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (unless (file-directory-p pub-dir)a
    (make-directory pub-dir t))
  (let ((output (expand-file-name (file-name-nondirectory filename) pub-dir)))
    (unless (file-equal-p (expand-file-name (file-name-directory filename))
			  (file-name-as-directory (expand-file-name pub-dir)))
      (shell-comm)
      (copy-file filename output t))
    ;; Return file name.
    output))

(defun my-html-format-drawer-function (name contents)
  "Turn drawer into an HTML element. In particular it works on :HISTORY: drawer.
NAME name of the drawer, CONTENTS value of the drawer."
  (pcase (upcase name)
    ("CREATED" (format "<div class='history created'>%s</div>" contents))
    ("UPDATED" (format "<div class='history updated'>%s</div>" contents))
    (_  contents)))

;;; Publishing Project
(setf org-publish-project-alist
      `(
        ("evgeniysharapov.com" :components ("content" "blog" "assets" "content-images"))
        ; main content with projects, articles, etc
        ("content"
         :base-directory ,*site-content-dir*
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,*site-output-dir*
         :publishing-function org-html-publish-to-html
         :recursive t          ; descend into sub-folders?
         :exclude "^blog"
         ;; Content of each file
         :with-drawers t
         :with-properties t
         :html-format-drawer-function my-html-format-drawer-function
         :section-numbers nil  ; don't create numbered sections
         :headline-level 4
         :with-author t
         :with-date t
         :with-tags nil
         :with-toc nil
         :htmlized-source t         
         :html-head ,(html "header")
         :html-preamble ,(html "nav")
         :html-postamble ,(html "footer"))

        ; blog content has sitemap that is a list of posts
        ("blog"
         :base-directory ,(filename *site-content-dir* "blog")
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,(filename *site-output-dir* "blog")
         :publishing-function org-html-publish-to-html
         :recursive t          ; descend into sub-folders?
         ;; Content of each file
         :section-numbers nil  ; don't create numbered sections
         :with-author t
         :with-date t
         :with-toc nil         ; don't create a table of contents
         :with-tags nil
         :htmlized-source t
         :html-head ,(html "header-blog")
         :html-preamble ,(html "nav")
         :html-postamble ,(html "footer")
         ;; Sitemap
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Blog"
         :sitemap-sort-files anti-chronologically
         :sitemap-function blog-sitemap-function
         :sitemap-format-entry blog-sitemap-format-entry
         :sitemap-date-format "Published %d %b %d %Y")

        ;; assets, css/fonts/js
        ("assets"
         :base-directory ,*site-assets-dir*
         :publishing-directory ,(filename *site-output-dir* "assets")
         :base-extension "css\\|js\\|ttf\\|woff2\\|jpg\\|jpeg\\|gif\\|png\\|pdf\\|svg"
         :recursive t
	 :publishing-function org-publish-attachment)
        ;; ("sass-assets"
        ;;  :base-directory ,site-assets-dir
        ;;  :publishing-directory ,(concat site-publish-dir "/assets")
        ;;  :base-extension "scss\\|sass"
        ;;  :recursive t
	;;  :publishing-function sass-compile-publish
        ;;  )        
        ;; images
        ("content-images"
         :base-directory ,(filename *site-content-dir* "images")
         :publishing-directory ,(filename *site-output-dir* "images")
         :base-extension "jpg\\|jpeg\\|gif\\|png\\|pdf\\|svg"
         :recursive t
	 :publishing-function org-publish-attachment)
        )
      )
