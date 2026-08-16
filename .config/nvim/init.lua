vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({

  -- ============================================================
  -- GRUPO: LSP / LENGUAJES
  -- Todo lo relacionado a soporte de lenguajes vive junto acá:
  -- treesitter (sintaxis) -> mason (instalador) ->
  -- mason-lspconfig (puente) -> nvim-lspconfig (LSP en sí) ->
  -- LuaSnip + nvim-cmp (autocompletado y snippets)
  --
  -- Para agregar un lenguaje nuevo, tocás 3 lugares (marcados
  -- con "AGREGAR ACÁ" más abajo):
  --   1. ensure_installed de treesitter (parser de sintaxis)
  --   2. ensure_installed de mason-lspconfig (instala el LSP)
  --   3. la lista `servers` de nvim-lspconfig (lo activa)
  -- ============================================================

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- AGREGAR ACÁ: parsers de treesitter
        ensure_installed = { "cpp", "c", "python", "lua", "bash", "toml" },
        highlight = { enable = true },
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- AGREGAR ACÁ: nombres de servidor LSP (según Mason)
        ensure_installed = { "clangd", "pyright", "lua_ls", "bashls", "taplo"},
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- AGREGAR ACÁ: mismo nombre que pusiste arriba en mason-lspconfig
      local servers = { "clangd", "pyright", "bashls", "taplo" }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
        vim.lsp.enable(server)
      end

      vim.lsp.config('lua_ls', {
	      capabilities = capabilities,
	      settings = {
		      lua = {
			      diagnostics = {
				      globals = { "vim" },
			      },
		      },
	      },
      })

      vim.lsp.enable('lua_ls')

    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },

  -- ============================================================
  -- GRUPO: NAVEGACIÓN / ARCHIVOS
  -- ============================================================

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons"},
    config = function() require("nvim-tree").setup() end
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = " Buscar archivo" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = " Buscar texto en proyecto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = " Buscar buffer abierto" },
    },
  },

  -- ============================================================
  -- GRUPO: EDICIÓN
  -- ============================================================

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- ============================================================
  -- GRUPO: GIT
  -- ============================================================

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, "Siguiente cambio")

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            -- CORREGIDO: era gs.prey_hunk(), no existía esa función
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, "Anterior cambio")

          map("n", "<leader>hp", gs.preview_hunk, "Previsualizar cambio flotante")
          map("n", "<leader>hd", gs.diffthis, "Ver diff contra el último commit")
        end,
      })
    end,
  },

  -- ============================================================
  -- GRUPO: APARIENCIA
  -- ============================================================

  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("catppuccin-mocha")
  --   end,
  -- },	 
  {
	"nvim-tree/nvim-web-devicons",
	config = function()
		require("nvim-web-devicons").setup({})
	end,
  },

  {
	  "metalelf0/black-metal-theme-neovim",
	  lazy = false,
	  priority = 1000,
	  config = function()
		  require("black-metal").setup({
			  theme = "immortal",
		  })
		  require("black-metal").load()
	  end,
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
      })
    end,
  },

  -- ============================================================
  -- GRUPO: AYUDA / PRODUCTIVIDAD
  -- ============================================================

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- ============================================================
  -- DESACTIVADO
  -- ============================================================

  {
    "andweeb/presence.nvim",
    config = function()
      require("presence").setup({
        auto_update = true,
        main_image = "file",
      })
    end,
  },
})

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

vim.opt.number = true
vim.opt.wrap = false
