
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(setq user-full-name "Matthew Daiter")
(setq user-mail-address "mdaiter8121@gmail.com")

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(setq tab-width 2
      indent-tabs-mode nil)

(setq make-backup-files nil)

(defalias 'yes-or-no-p 'y-or-n-p)

;; (require 'server)
;; (server-start)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(setq package-archive-enable-alist
      '(
        ("melpa"
          elixir-mode elixir-yasnippets flymake-elixir
        )
       )
)

(defvar mdaiter/packages
  '(
    elixir-mode
    elixir-yasnippets

    flymake
    flymake-elixir

    neotree
  )
)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (highlight ivy alchemist neotree flymake-easy flymake-elixir elixir-yasnippets elixir-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(neo-banner-face ((t :inherit shadow)))
 '(neo-button-face ((t :inherit dired-directory)))
 '(neo-dir-link-face ((t :inherit dired-directory)))
 '(neo-expand-btn-face ((t :inherit button)))
 '(neo-file-link-face ((t :inherit default)))
 '(neo-header-face ((t :inherit shadow)))
 '(neo-root-dir-face ((t :inherit link-visited :underline nil))))

;; Highlights
(defun mdaiter/turn-on-hl-line-mode ()
  (when (> (display-color-cells) 8)
    (hl-line-mode t)))

(defun mdaiter/add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|HACK\\|REFACTOR\\|NOCOMMIT\\)"
          1 font-lock-warning-face t))))

;;(add-hook 'prog-mode-hook 'mdaiter/turn-on-hl-line-mode)
;;(add-hook 'prog-mode-hook 'mdaiter/add-watchwords)

(require 'hl-line)
(set-face-background 'hl-line "red")
(show-paren-mode t)

;; Whitespace

(require 'whitespace)

(unless (member 'whitespace-mode prog-mode-hook)
  (add-hook 'prog-mode-hook 'whitespace-mode))
(global-set-key (kbd "C-c w") 'whitespace-cleanup)
(set-default 'indicate-empty-lines t)
(set-default 'indent-tabs-mode nil)
(setq whitespace-style '(face trailing lines-tail tabs)
      whitespace-line-column 80)

(defun mdaiter/untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun mdaiter/indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun mdaiter/cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (mdaiter/indent-buffer)
  (mdaiter/untabify-buffer)
  (delete-trailing-whitespace))

(global-set-key (kbd "C-c n") 'mdaiter/cleanup-buffer)


;; Comments
(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)))

(global-set-key (kbd "M-/") 'comment-or-uncomment-region-or-line)
(global-set-key (kbd "M-\\") 'dabbrev-expand)

;;; ERLANG

(defconst mdaiter/erlang/root
  "/usr/local/Cellar/erlang"
  "The root directory where various versions of Erlang are installed")

(defvar mdaiter/erlang/latest
  "22.0.7"
  "The latest version of Erlang installed.")

(defvar mdaiter/erlang/latest/tools-version
  "3.2"
  "The version of the 'tools' application in the latest Erlang.")

(defun mdaiter/erlang/latest/root ()
  "Computes the root directory of the latest Erlang installed."
  (expand-file-name mdaiter/erlang/latest mdaiter/erlang/root))

(defun mdaiter/erlang/latest/bin ()
  "Computes the latest Erlang's executable directory"
  (expand-file-name "bin" (mdaiter/erlang/latest/root)))

(defun mdaiter/erlang/latest/lib ()
  "Computes the latest Erlang's library directory"
  (expand-file-name "erlang" (expand-file-name "lib" (mdaiter/erlang/latest/root))))

(defun mdaiter/erlang/latest/emacs ()
  "Computes the location of the OTP emacs mode."
  (cl-reduce 'expand-file-name
             (list "emacs"
                   (format "tools-%s" mdaiter/erlang/latest/tools-version)
                   "lib"
                   (mdaiter/erlang/latest/lib))
             :from-end t))

(add-to-list 'load-path (mdaiter/erlang/latest/emacs))
(add-to-list 'exec-path (mdaiter/erlang/latest/bin))
(setq erlang-root-dir (mdaiter/erlang/latest/lib))
(require 'erlang-start)

(add-hook 'erlang-mode-hook 'mdaiter/add-watchwords)
(add-hook 'erlang-mode-hook 'mdaiter/turn-on-hl-line-mode)
(add-hook 'erlang-mode-hook 'whitespace-mode)

(add-to-list 'auto-mode-alist '("rebar.config" . erlang-mode)) ;; rebar
(add-to-list 'auto-mode-alist '("rebar.config.script" . erlang-mode)) ;; rebar
(add-to-list 'auto-mode-alist '("app.config" . erlang-mode)) ;; embedded node/riak
(add-to-list 'auto-mode-alist '(".riak_test.config" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.erlang$" . erlang-mode)) ;; User customizations file

(require 'erlang-flymake)
(setq erlang-flymake-command (expand-file-name "erlc" (mdaiter/erlang/latest/bin)))

(defun rebar3/erlang-flymake-get-include-dirs ()
  (append
     (erlang-flymake-get-include-dirs)
     (file-expand-wildcards (concat (erlang-flymake-get-app-dir) "_build/*/lib")))
)

(setq erlang-flymake-get-include-dirs-function 'rebar3/erlang-flymake-get-include-dirs)

(defun rebar3/erlang-flymake-get-code-path-dirs ()
  (append
     (erlang-flymake-get-code-path-dirs)
     (file-expand-wildcards (concat (erlang-flymake-get-app-dir) "_build/*/lib/*/ebin"))))

(setq erlang-flymake-get-code-path-dirs-function 'rebar3/erlang-flymake-get-code-path-dirs)

(defvar mdaiter/erlang/eqc-version
  "2.01.0"
  "The latest version of EQC I have installed.")

(defun mdaiter/erlang/eqc/root ()
   "Computes the location of the latest EQC app."
   (cl-reduce 'expand-file-name
              (list (format "eqc-%s" mdaiter/erlang/eqc-version)
                    mdaiter/erlang/eqc-version
                    "eqc"
                    mdaiter/erlang/root)
     :from-end t))

;; Because Erlang binaries are a pain to type

(defun erlang-insert-binary ()
  "Inserts a binary string into an Erlang buffer and places the
  point between the quotes."
  (interactive)
  (insert "<<\"\">>")
  (backward-char 3)
  )
(eval-after-load "erlang" '(define-key erlang-mode-map (kbd "C-c b") 'erlang-insert-binary))


;; ELIXIR

(require 'elixir-mode)
;; Create a buffer-local hook to run elixir-format on save, only when we enable elixir-mode.
(add-hook 'elixir-mode-hook
          (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))

(add-to-list 'elixir-mode-hook 'alchemist-mode)
(add-to-list 'elixir-mode-hook 'company-mode)
;;(add-to-list 'elixir-mode-hook 'ruby-end-mode)
(setq alchemist-mix-command "/usr/local/bin/mix")
(setq alchemist-iex-program-name "/usr/local/bin/iex")
(setq alchemist-compile-command "/usr/local/bin/elixirc")
(setq alchemist-key-command-prefix (kbd "C-c a"))

(defadvice alchemist-project-root (around mdaiter/alchemist-project-root activate)
  (let ((alchemist-project-mix-project-indicator ".git"))
    ad-do-it))

(defun mdaiter/activate-alchemist-root-advice ()
  "Activates advice to override alchemist's root-finding logic"
  (ad-activate 'alchemist-project-root))

(add-to-list 'elixir-mode-hook 'mdaiter/activate-alchemist-root-advice)

;; C++


;; Helm
(require 'helm-config)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(helm-mode 1)

;; Neotree

(require 'neotree)
  (global-set-key [f8] 'neotree-toggle)

(setq neo-theme 'ascii)

