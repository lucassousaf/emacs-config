;; Using straight.el and use-package.el for packages management and
;; configuration. This is a mix of things I borrowed and tweaked, and
;; others I added myself.

;;; Code:

;; disable package.el

(setq package-enable-at-startup nil)

;; straight.el

(defvar bootstrap-version)

(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
			 user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
	 'silent
	 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package

(straight-use-package 'use-package)

;; Remove toolbar
(menu-bar-mode -1)

;; theme

(use-package doom-themes
  :straight t
  :init
  :config
  (setq doom-themes-enable-bold t)
  (load-theme 'doom-dark+ t))

;; clojure-mode

(use-package clojure-ts-mode
  :straight t
  :hook ((clojure-ts-mode . cider-mode)
	 (clojure-ts-mode . enable-paredit-mode)
	 (clojure-ts-clojurescript-mode . enable-paredit-mode)
	 (clojure-ts-clojurec-mode . enable-paredit-mode))
  :mode (("\\.clj\\'" . clojure-ts-mode)
	 ("\\.cljs\\'" . clojure-ts-clojurescript-mode)
	 ("\\.cljc\\'" . clojure-ts-clojurec-mode)
	 ("\\.edn\\'" . clojure-ts-mode)
	 ("\\.bb\\'" . clojure-ts-mode)))

(use-package clojure-mode
  :straight t)

;; cider

(use-package cider
  :straight t
  :custom
  ((cider-repl-use-pretty-printing t)
   (cider-print-fn 'fipp)
   (cider-print-quota 20480 "Set it to 20k (default is 1M)")
   (cider-repl-display-help-banner nil)
   (cider-repl-use-content-types nil)
   (cider-known-endpoints '(("docker" "127.0.0.1" "4001")))
   (cider-eldoc-display-for-symbol-at-point nil)
   (cider-repl-prompt-function 'cider-repl-prompt-abbreviated))
  :config
  (remove-hook 'eldoc-documentation-functions #'cider-eldoc)
  :hook
  ((cider-repl-mode . subword-mode)))

;; paredit

(use-package paredit
  :straight t
  :bind
  ;; Paredit 25+ binds RET to `paredit-RET`. This can cause
  ;; unexpected behaviour in the REPL when paredit-mode is enabled,
  ;; e.g. it appears to hang after hitting RET instead of evaluating
  ;; the last form. Set that binding to `nil` to disable that
  ;; behaviour.
  (:map paredit-mode-map ("RET" . nil))
  :hook
  ((emacs-lisp-mode . enable-paredit-mode)
   (cider-repl-mode . paredit-mode)))

;; company

(use-package company
  :straight t
  :custom
  ;; Lower the number of characters that triggers completion (the default is 3).
  (company-minimum-prefix-length 2)
  ;; Show numbers for the completion options. Press M-<number> to select it.
  (company-show-numbers t)
  ;; Selecting item before first or after last wraps around.
  (company-selection-wrap-around t)
  :config
  (global-company-mode)
  :hook
  ((cider-mode . company-mode)
   (cider-repl-mode . company-mode)
   (cider-mode . cider-company-enable-fuzzy-completion)
   (cider-repl-mode . cider-company-enable-fuzzy-completion)))

;; rainbow-delimiters

(use-package rainbow-delimiters
  :straight t
  :hook
  ((emacs-lisp-mode . rainbow-delimiters-mode)
   (clojure-ts-mode . rainbow-delimiters-mode)
   (clojure-ts-clojurescript-mode . rainbow-delimiters-mode)
   (cider-repl-mode . rainbow-delimiters-mode)))

;; magit

(defun seq-keep (function sequence)
  "Apply FUNCTION to SEQUENCE and return the list of all the non-nil results."
  (delq nil (seq-map function sequence)))

(use-package magit
  :straight t
  :custom
  ;; Set transient LEVEL to the maximum (expert mode, so to
  ;; speak). It's 4 by default, and it hides some advanced options
  ;; that I use from time to time.
  (transient-default-level 7)
  ;; Enable the --sign option of magit-tag by default.
  (transient-values '((magit-tag "--sign")))
  :bind
  ("C-x g" . magit-status))

;; flycheck

(use-package flycheck
  :straight t
  :hook
  ((after-init . global-flycheck-mode)))

;; flycheck-clj-kondo

(use-package flycheck-clj-kondo
  :disabled
  :straight t)

;; web-mode

(use-package web-mode
  :straight t)

;; yaml-mode

(use-package yaml-mode
  :straight t
  :mode (("\\.yml'" . yaml-mode)
         ("\\.yaml'" . yaml-mode)))

;; markdown-mode

(use-package markdown-mode
  :straight t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
           ("\\.markdown\\'" . markdown-mode)))

;; ripgrep

(use-package ripgrep
  :straight t
  :custom
  ;; Look into hidden directorys and files too (but respect 'ignore' files)
  ;; and do case insensitive search
  (ripgrep-arguments '("--hidden" "--ignore-case")))

;; projectile

(use-package projectile
  :straight t
  :init
  (projectile-mode +1)
  :bind
  (:map projectile-mode-map ("C-c p" . projectile-command-map)))

;; lsp-mode

(use-package lsp-mode
  :straight t
  :custom
  (lsp-client-packages '(lsp-clojure))
  (gc-cons-threshold (* 100 1024 1024))
  (read-process-output-max (* 1024 1024))
  ;; Don't want lenses, it clutters the display when using Emacs in
  ;; terminal mode. I'm not sure about this configuration. I need to
  ;; review it. Sometimes is nice to have the lenses there.
  (lsp-lens-enable nil)
  (lsp-signature-auto-activate nil)
  (lsp-enable-snippet nil)
  (lsp-enable-indentation t)
  (lsp-enable-completion-at-point t)
  (lsp-eldoc-enable-hover t)
  (lsp-enable-symbol-highlighting t)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-code-actions-enable t)
  :config
  (dolist (m '(clojure-ts-mode
	       clojure-ts-clojurescript-mode
	       clojure-ts-clojurec-mode))
    (add-to-list 'lsp-language-id-configuration `(,m . "clojure")))
  :hook
  ((clojure-ts-mode . lsp)
   (clojure-ts-clojurescript-mode . lsp)
   (clojure-ts-clojurec-mode . lsp))
  :bind
  (("M-." . lsp-find-definition)
   ("C-c l r" . lsp-rename)
   ("C-c l d" . lsp-describe-thing-at-point)
   ("C-c f i" . lsp-find-implementation)
   ("C-c f r" . lsp-find-references)
   ("C-c f d" . lsp-find-definition)
   ("C-c l a" . lsp-clojure-add-missing-libspec)
   ("C-c l c n" . lsp-clojure-clean-ns)
   ("C-c l f b" . lsp-format-buffer)))

;; lsp-ui

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode)

;; flx-ido

(use-package flx-ido
  :straight t
  :custom
  ;; Disable ido faces to see flx highlights.
  (ido-enable-flex-matching t)
  (ido-use-faces nil)
  ;; Raise the garbage collection threshold to 20M of allocated memory
  ;; (it's 0.76 MB by default). It reduces the time spent garbage
  ;; collecting, while dealing with large projects (see benchmarks at
  ;; the end of https://github.com/lewang/flx
  (gc-cons-threshold 20480000)
  :config
  (ido-mode +1)
  (ido-everywhere +1)
  (flx-ido-mode +1))

;; ace-window

(use-package ace-window
  :straight t
  :custom
  ;; Configure it to use the following letters to select windows,
  ;; instead of numbers.
  (aw-keys '(?a ?b ?c ?d ?e ?f ?g ?h ?i))
  (aw-scope 'frame)
  :bind
  ("C-x o" . ace-window))

;; aggresive-indent-mode

(use-package aggressive-indent
  :straight t
  :hook
  ((clojure-mode . aggressive-indent-mode)
   (clojurescript--mode . aggressive-indent-mode)))

;; treemacs

(use-package treemacs
  :straight t
  :init
  ;; Silence load-time warnings about not finding icon colors, etc
  (defvar treemacs-no-load-time-warnings t))

;; lsp-treemacs

(use-package lsp-treemacs
  :straight t)

;; xclip

(use-package xclip
  :straight t
  :config
  (xclip-mode 1))

;; sqlformatter

(use-package sqlformat
  :straight t
  :config
  (setq sqlformat-command 'pgformatter)
  (setq sqlformat-args '("--type-case" "2" "--comma-break"))
  ;; This can be a little annoying if you are using SQL keywords as
  ;; column names. The formatting program makes them uppercase by
  ;; default and I don't want that. This can also happen in other use
  ;; cases that I can't remember now the details. In any case, it's
  ;; better to keep it disabled and format manually using the
  ;; keybinding.
  ;;
  ;; :hook
  ;; (sql-mode . sqlformat-on-save-mode)
  :bind
  (:map sql-mode-map ("C-c C-f" . sqlformat)))

;; css

(use-package css-mode
  :straight t
  :custom
  (css-indent-offset 2))

;; scss

(use-package scss-mode
  :straight t
  :custom
  (scssc-compile-at-save nil)
  :mode
  ("\\.scss\\'" . scss-mode))

;; uuidgen

(use-package uuidgen
  :straight t)

;; restclient

(use-package restclient
  :straight t)

;; git-link

(use-package git-link
  :straight t
  :bind
  (("C-c g l" . git-link)))

;; origami

(use-package dash
  :straight t)

(use-package s
  :straight t)

(use-package origami
  :straight t
  :bind
  (("C-c o c" . origami-close-node)
   ("C-c o o" . origami-open-node)))

;; misc

;; Make sure trailing white space and tabs are visually highlighted.
(setq-default whitespace-style '(face trailing tabs))
(global-whitespace-mode +1)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5    ; and how many of the old
  )
