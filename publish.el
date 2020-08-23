(require 'ox-html)
(require 'ox-publish)

;;; Code:
(defconst base-dir (file-name-directory load-file-name))
(defconst site-publish-dir (concat base-dir "/public"))
(defconst site-source-dir (concat base-dir "/src"))

;;; loading packages
(add-to-list 'load-path (concat  base-dir "/lisp"))

;; use styles for HTMLizing
(setq org-html-htmlize-output-type 'css)

;; fonts
;; <link href="https://fonts.googleapis.com/css2?family=Montserrat&family=Oswald&display=swap" rel="stylesheet">


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
         ;:with-toc t         ; don't create a table of contents
         :with-latex t         ; do use MathJax for awesome formulas!
        ; :html-head-extra ""   ; extra <head> entries go here
        ; :html-preamble ""     ; this stuff is put before your post
        ; :html-postamble ""    ; this stuff is put after your post         
         )
        ("site-static"
         :base-directory ,(concat  site-source-dir "/static")
         :base-extension "*"
         :recursive t
	 :publishing-function org-publish-attachment
         )))
