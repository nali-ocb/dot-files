{ system_lib, lib, pkgs, pkgs_unstable, ... }@inputs:

{
  home.packages = with pkgs; [
    (system_lib.bwrapIt {
      name = "emacs";
      package = ((emacsPackagesFor emacs).emacsWithPackages
        (
          epkgs: (with epkgs; [
            #
            # GENERAL
            #
            use-package
            evil # vim emulator
            undo-tree # required by evil
            #
            # KEYMAPS
            #
            which-key
            ivy # completion (+minibuffer)
            counsel # required by ivy (ivy-enhanced collection)
            swiper # required by ivy (alternative to Isearch)
            #general
            #
            # THEMES
            #
            doom-themes
            #
            # FILES
            #
            treemacs
            treemacs-evil
            treemacs-magit
            treemacs-all-the-icons
            lsp-treemacs
            #projectile
            #
            # GIT
            #
            magit
            #
            # LANGUAGES
            #
            eglot # lsp
            company
            elixir-mode
            #tree-sitter
            #tree-sitter-langs
          ])
        ));
      args = "$@";
      binds = [
        "~/.emacs.d"
        "~/projects"
      ];
    })
  ];

  home.file = {
    ".emacs.d/init.el".text = ''
      ;;; NOTE:
      ;;; In case of any errors, use: 
      ;;; emacs --debug-init

      ;;;;;;;;;;;;;
      ;; GENERAL ;;
      ;;;;;;;;;;;;;
      (setq standard-indent 2)

      (setq font-lock-maximum-decoration t)

      ;; disable menu, toolbar and scrollbar
      (menu-bar-mode -1)
      (scroll-bar-mode -1)
      (tool-bar-mode -1)

      ;;;;;;;;;;;;;;;
      ;; UNDO-TREE ;; (used by evil)
      ;;;;;;;;;;;;;;;
      (global-undo-tree-mode)

      ;;;;;;;;;;
      ;; EVIL ;;
      ;;;;;;;;;;
      (use-package evil
        :ensure t
        :config
        (setq evil-undo-system "undo-tree")

        (define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)

        (evil-set-leader nil (kbd "SPC") nil)

        ;; WindMove (builtin)
        ;; https://www.emacswiki.org/emacs/WindMove
        (evil-define-key nil 'global (kbd  "C-<left>") 'windmove-left)
        (evil-define-key nil 'global (kbd  "C-<right>") 'windmove-right)
        (evil-define-key nil 'global (kbd  "C-<up>") 'windmove-up)
        (evil-define-key nil 'global (kbd  "C-<down>") 'windmove-down)

        (evil-mode 1)) ; needs to be the last

      ;;;;;;;;;;;;;;;
      ;; WHICH-KEY ;;
      ;;;;;;;;;;;;;;;
      (which-key-mode)

      ;;;;;;;;;
      ;; IVY ;;
      ;;;;;;;;;
      (ivy-mode)
      (setq ivy-use-virtual-buffers t)
      (setq enable-recursive-minibuffers t)
      ;; enable this if you want `swiper' to use it
      ;; (setq search-default-mode #'char-fold-to-regexp)
      (global-set-key "\C-s" 'swiper)
      (global-set-key (kbd "C-c C-r") 'ivy-resume)
      (global-set-key (kbd "<f6>") 'ivy-resume)
      (global-set-key (kbd "M-x") 'counsel-M-x)
      (global-set-key (kbd "C-x C-f") 'counsel-find-file)
      (global-set-key (kbd "<f1> f") 'counsel-describe-function)
      (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
      (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
      (global-set-key (kbd "<f1> l") 'counsel-find-library)
      (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
      (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
      (global-set-key (kbd "C-c g") 'counsel-git)
      (global-set-key (kbd "C-c j") 'counsel-git-grep)
      (global-set-key (kbd "C-c k") 'counsel-ag)
      (global-set-key (kbd "C-x l") 'counsel-locate)
      (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
      (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

      ;;;;;;;;;;;
      ;; EGLOT ;;
      ;;;;;;;;;;;
      ;; automatically runs `M-x eglot` when in `LANGUAGE-mode`
      (use-package eglot
        :ensure t
        :config
        (add-hook 'elixir-mode-hook 'eglot-ensure)
        (add-to-list 'eglot-server-programs '(elixir-mode "elixir-ls")))

      ;;;;;;;;;;;;;
      ;; COMPANY ;;
      ;;;;;;;;;;;;;
      (global-company-mode)

      ;;;;;;;;;;;;;;;;;
      ;; DOOM THEMES ;;
      ;;;;;;;;;;;;;;;;;
      (use-package doom-themes
        :ensure t
        :config
        ;; Global settings (defaults)
        (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
              doom-themes-enable-italic t) ; if nil, italics is universally disabled
        (load-theme 'doom-one t)

        ;; Enable flashing mode-line on errors
        (doom-themes-visual-bell-config)
        ;; Enable custom neotree theme (all-the-icons must be installed!)
        (doom-themes-neotree-config)
        ;; or for treemacs users
        (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
        (doom-themes-treemacs-config)
        ;; Corrects (and improves) org-mode's native fontification.
        (doom-themes-org-config))

      ;;;;;;;;;;;;;;
      ;; THEEMACS ;;
      ;;;;;;;;;;;;;;
      (use-package treemacs
        :ensure t
        :defer t
        :init
        (with-eval-after-load 'winum
          (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
        :config
        (progn
          (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
                treemacs-deferred-git-apply-delay        0.5
                treemacs-directory-name-transformer      #'identity
                treemacs-display-in-side-window          t
                treemacs-eldoc-display                   'simple
                treemacs-file-event-delay                5000
                treemacs-file-extension-regex            treemacs-last-period-regex-value
                treemacs-file-follow-delay               0.2
                treemacs-file-name-transformer           #'identity
                treemacs-follow-after-init               t
                treemacs-expand-after-init               t
                treemacs-find-workspace-method           'find-for-file-or-pick-first
                treemacs-git-command-pipe                ""
                treemacs-goto-tag-strategy               'refetch-index
                treemacs-header-scroll-indicators        '(nil . "^^^^^^")'
                treemacs-hide-dot-git-directory          t
                treemacs-indentation                     2
                treemacs-indentation-string              " "
                treemacs-is-never-other-window           nil
                treemacs-max-git-entries                 5000
                treemacs-missing-project-action          'ask
                treemacs-move-forward-on-expand          nil
                treemacs-no-png-images                   nil
                treemacs-no-delete-other-windows         t
                treemacs-project-follow-cleanup          nil
                treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
                treemacs-position                        'left
                treemacs-read-string-input               'from-child-frame
                treemacs-recenter-distance               0.1
                treemacs-recenter-after-file-follow      nil
                treemacs-recenter-after-tag-follow       nil
                treemacs-recenter-after-project-jump     'always
                treemacs-recenter-after-project-expand   'on-distance
                treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
                treemacs-show-cursor                     nil
                treemacs-show-hidden-files               t
                treemacs-silent-filewatch                nil
                treemacs-silent-refresh                  nil
                treemacs-sorting                         'alphabetic-asc
                treemacs-select-when-already-in-treemacs 'move-back
                treemacs-space-between-root-nodes        t
                treemacs-tag-follow-cleanup              t
                treemacs-tag-follow-delay                1.5
                treemacs-text-scale                      nil
                treemacs-user-mode-line-format           nil
                treemacs-user-header-line-format         nil
                treemacs-wide-toggle-width               70
                treemacs-width                           35
                treemacs-width-increment                 1
                treemacs-width-is-initially-locked       t
                treemacs-workspace-switch-cleanup        nil)
      
          ;; The default width and height of the icons is 22 pixels. If you are
          ;; using a Hi-DPI display, uncomment this to double the icon size.
          ;;(treemacs-resize-icons 44)
      
          (treemacs-follow-mode t)
          (treemacs-filewatch-mode t)
          (treemacs-fringe-indicator-mode 'always)
          (when treemacs-python-executable
            (treemacs-git-commit-diff-mode t))
      
          (pcase (cons (not (null (executable-find "git")))
                       (not (null treemacs-python-executable)))
            (`(t . t)
             (treemacs-git-mode 'deferred))
            (`(t . _)
             (treemacs-git-mode 'simple)))
      
          (treemacs-hide-gitignored-files-mode nil))
        :bind
        (:map global-map
              ("M-0"       . treemacs-select-window)
              ("C-x t 1"   . treemacs-delete-other-windows)
              ("C-x t t"   . treemacs)
              ("C-x t d"   . treemacs-select-directory)
              ("C-x t B"   . treemacs-bookmark)
              ("C-x t C-t" . treemacs-find-file)
              ("C-x t M-t" . treemacs-find-tag)))
      
      (use-package treemacs-evil
        :after (treemacs evil)
        :ensure t)
      
      (use-package treemacs-magit
        :after (treemacs magit)
        :ensure t)

      
      ;(require 'tree-sitter)
      ;(require 'tree-sitter-langs)
      ;(global-tree-sitter-mode)
    '';
  };
}
