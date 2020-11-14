;;; package --- Publishing website evgeniysharapov.com
;;
;;; Commentary:
;;   This is a custom Emacs Lisp script 

(require 'ox-html)
(require 'ox-publish)

;;; Code:
(defconst base-dir (file-name-directory (or load-file-name (buffer-file-name (current-buffer)))))
(defconst site-publish-dir (concat base-dir "public"))
(defconst site-source-dir (concat base-dir "src"))

;;; Extra Packages
(add-to-list 'load-path (concat  base-dir "lisp"))

;;; Fonts
;; <link href="https://fonts.googleapis.com/css2?family=Montserrat&family=Oswald&display=swap" rel="stylesheet">

;;; Org HTML Setup
(setf org-html-doctype "html5"
      org-html-html5-fancy t
      ;; use styles for HTMLizing
      org-html-htmlize-output-type 'css
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


(setf org-publish-project-alist
      `(
        ("site" :components ("site-content" "site-static"))
        ("site-content"
         :base-directory ,site-source-dir
         :html-extension "html"
         :base-extension "org"
         :publishing-directory ,site-publish-dir
         :publishing-function org-html-publish-to-html
         :htmlized-source t
         :recursive t          ; descend into sub-folders?
         :section-numbers nil  ; don't create numbered sections
         :with-toc nil         ; don't create a table of contents
         :with-latex t         ; do use MathJax for awesome formulas!
         :html-link-home "/"

         ;; sitemap
         :auto-sitemap t
         :sitemap-filename "site.org"
         :sitemap-title "Site"
         :sitemap-sort-files anti-chronologically
         :sitemap-date-format "Published %d %b %d %Y"
         )
        ("site-static"
         :base-directory ,(concat  base-dir "/static")
         :base-extension "*"
         :recursive t
	 :publishing-function org-publish-attachment
         )))
