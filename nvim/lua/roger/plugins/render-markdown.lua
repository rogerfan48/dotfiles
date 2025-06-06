return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  config = function()
    require("render-markdown").setup({
      sign = { enabled = false },
      heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Additional modes to render headings
        render_modes = false,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the list using a cycle
        -- If the value is a function the input is the nesting level of the heading within sections
        -- icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
        -- Determines how icons fill the available space:
        --  right:   '#'s are concealed and icon is appended to right side
        --  inline:  '#'s are concealed and icon is inlined on left side
        --  overlay: icon is left padded with spaces and inserted on left hiding any additional '#'
        position = "overlay",
        -- Added to the sign column if enabled
        -- The 'level' is used to index into the list using a cycle
        signs = { "󰫎 " },
        -- Width of the heading background:
        --  block: width of the heading text
        --  full:  full width of the window
        -- Can also be a list of the above values in which case the 'level' is used
        -- to index into the list using a clamp
        width = "full",
        -- Amount of margin to add to the left of headings
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Margin available space is computed after accounting for padding
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        left_margin = 0,
        -- Amount of padding to add to the left of headings
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        left_pad = 0,
        -- Amount of padding to add to the right of headings when width is 'block'
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        right_pad = 0,
        -- Minimum width to use for headings when width is 'block'
        -- Can also be a list of integers in which case the 'level' is used to index into the list using a clamp
        min_width = 0,
        -- Determines if a border is added above and below headings
        -- Can also be a list of booleans in which case the 'level' is used to index into the list using a clamp
        border = false,
        -- Always use virtual lines for heading borders instead of attempting to use empty lines
        border_virtual = false,
        -- Highlight the start of the border using the foreground highlight
        border_prefix = false,
        -- Used above heading for border
        above = "▄",
        -- Used below heading for border
        below = "▀",
        -- The 'level' is used to index into the list using a clamp
        -- Highlight for the heading icon and extends through the entire line
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        -- The 'level' is used to index into the list using a clamp
        -- Highlight for the heading and sign icons
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      quote = {
        -- Turn on / off block quote & callout rendering
        enabled = true,
        -- Additional modes to render quotes
        render_modes = false,
        -- Replaces '>' of 'block_quote'
        icon = "▋",
        -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text if
        -- not configured correctly with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'. A
        -- combination of these that is likely to work is showbreak = '  ' (2 spaces), breakindent = true,
        -- breakindentopt = '' (empty string). These values are not validated by this plugin. If you want
        -- to avoid adding these to your main configuration then set them in win_options for this plugin.
        repeat_linebreak = true,
        -- Highlight for the quote icon
        highlight = "RenderMarkdownQuote",
      },

      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
        abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
        summary = { raw = "[!SUMMARY]", rendered = "󰨸 Summary", highlight = "RenderMarkdownInfo" },
        tldr = { raw = "[!TLDR]", rendered = "󰨸 Tldr", highlight = "RenderMarkdownInfo" },
        info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
        todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
        hint = { raw = "[!HINT]", rendered = "󰌶 Hint", highlight = "RenderMarkdownSuccess" },
        success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
        check = { raw = "[!CHECK]", rendered = "󰄬 Check", highlight = "RenderMarkdownSuccess" },
        done = { raw = "[!DONE]", rendered = "󰄬 Done", highlight = "RenderMarkdownSuccess" },
        question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
        help = { raw = "[!HELP]", rendered = "󰘥 Help", highlight = "RenderMarkdownWarn" },
        faq = { raw = "[!FAQ]", rendered = "󰘥 Faq", highlight = "RenderMarkdownWarn" },
        attention = { raw = "[!ATTENTION]", rendered = "󰀪 Attention", highlight = "RenderMarkdownWarn" },
        failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
        fail = { raw = "[!FAIL]", rendered = "󰅖 Fail", highlight = "RenderMarkdownError" },
        missing = { raw = "[!MISSING]", rendered = "󰅖 Missing", highlight = "RenderMarkdownError" },
        danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
        error = { raw = "[!ERROR]", rendered = "󱐌 Error", highlight = "RenderMarkdownError" },
        bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
        example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
        quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
        cite = { raw = "[!CITE]", rendered = "󱆨 Cite", highlight = "RenderMarkdownQuote" },
      },

      checkbox = {
        enabled = true,
        position = "inline",
        unchecked = { icon = "󰄱", highlight = "RenderMarkdownUnchecked", scope_highlight = nil },
        checked = { icon = "󰱒", highlight = "RenderMarkdownChecked", scope_highlight = nil },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔", highlight = "RenderMarkdownTodo", scope_highlight = nil },
          right_arrow = { raw = "[>]", rendered = "", highlight = "RenderMarkdownInfo", scope_highlight = nil },
          important = { raw = "[!]", rendered = "", highlight = "RenderMarkdownWarn", scope_highlight = nil },
        },
      },

      code = {
        -- Turn on / off code block & inline code rendering
        enabled = true,
        -- Additional modes to render code blocks
        render_modes = false,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how code blocks & inline code are rendered:
        --  none:     disables all rendering
        --  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
        --  language: adds language icon to sign column if enabled and icon + name above code blocks
        --  full:     normal + language
        style = "full",
        -- Determines where language icon is rendered:
        --  right: right side of code block
        --  left:  left side of code block
        position = "right",
        -- Amount of padding to add around the language
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        language_pad = 1,
        -- Whether to include the language name next to the icon
        language_name = true,
        -- A list of language names for which background highlighting will be disabled
        -- Likely because that language has background highlights itself
        -- Or a boolean to make behavior apply to all languages
        -- Borders above & below blocks will continue to be rendered
        disable_background = { "diff" },
        -- Width of the code block background:
        --  block: width of the code block
        --  full:  full width of the window
        width = "block",
        -- Amount of margin to add to the left of code blocks
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Margin available space is computed after accounting for padding
        left_margin = 0,
        -- Amount of padding to add to the left of code blocks
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks when width is 'block'
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        right_pad = 6,
        -- Minimum width to use for code blocks when width is 'block'
        min_width = 40,
        -- Determines how the top / bottom of code block are rendered:
        --  none:  do not render a border
        --  thick: use the same highlight as the code body
        --  thin:  when lines are empty overlay the above & below icons
        border = "thin",
        -- Used above code blocks for thin border
        above = "▄",
        -- Used below code blocks for thin border
        below = "▀",
        -- Highlight for code blocks
        highlight = "RenderMarkdownCode",
        -- Highlight for language, overrides icon provider value
        highlight_language = nil,
        -- Padding to add to the left & right of inline code
        inline_pad = 0,
        -- Highlight for inline code
        highlight_inline = "RenderMarkdownCodeInline",
      },

      dash = {
        -- Turn on / off thematic break rendering
        enabled = true,
        -- Additional modes to render dash
        render_modes = false,
        -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
        -- The icon gets repeated across the window's width
        icon = " ̶", -- "─",
        -- Width of the generated line:
        --  <number>: a hard coded width value, if a floating point value < 1 is provided it is
        --            treated as a percentage of the available window space
        --  full:     full width of the window
        width = "full",
        -- Amount of margin to add to the left of dash
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        left_margin = 0,
        -- Highlight for the whole line generated from the icon
        highlight = "RenderMarkdownDash",
      },

      -- Mimic org-indent-mode behavior by indenting everything under a heading based on the
      -- level of the heading. Indenting starts from level 2 headings onward.
      indent = {
        -- Turn on / off org-indent-mode
        enabled = false,
        -- Additional modes to render indents
        render_modes = false,
        -- Amount of additional padding added for each heading level
        per_level = 2,
        -- Heading levels <= this value will not be indented
        -- Use 0 to begin indenting from the very first level
        skip_level = 1,
        -- Do not indent heading titles, only the body
        skip_heading = false,
      },

      latex = {
        enabled = false,
        converter = "latex2text",
        highlight = "RenderMarkdownMath",
        top_pad = 0,
        bottom_pad = 0,
      },

      link = {
        enabled = true,
        footnote = {
          superscript = true,
          prefix = "",
          suffix = "",
        },
        image = "󰥶 ",
        email = " ",
        hyperlink = " ",
        highlight = "RenderMarkdownLink",
        wiki = { icon = "", highlight = "RenderMarkdownWikiLink" },
        custom = {
          web = { pattern = "^http", icon = "󰌹 ", highlight = "RenderMarkdownExternalLinkIcon" },
        },
      },

      bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
        -- Additional modes to render list bullets
        render_modes = false,
        -- Replaces '-'|'+'|'*' of 'list_item'
        -- How deeply nested the list is determines the 'level', how far down at that level determines the 'index'
        -- If a function is provided both of these values are passed in using 1 based indexing
        -- If a list is provided we index into it using a cycle based on the level
        -- If the value at that level is also a list we further index into it using a clamp based on the index
        -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
        -- icons = { "●", "○", "◆", "◇" },
        icons = { "" },
        -- Replaces 'n.'|'n)' of 'list_item'
        -- How deeply nested the list is determines the 'level', how far down at that level determines the 'index'
        -- If a function is provided both of these values are passed in using 1 based indexing
        -- If a list is provided we index into it using a cycle based on the level
        -- If the value at that level is also a list we further index into it using a clamp based on the index
        ordered_icons = function(ctx)
          local value = vim.trim(ctx.value)
          local index = tonumber(value:sub(1, #value - 1))
          return ("%d."):format(index > 1 and index or ctx.index)
        end,
        -- Padding to add to the left of bullet point
        left_pad = 0,
        -- Padding to add to the right of bullet point
        right_pad = 0,
        -- Highlight for the bullet icon
        highlight = "RenderMarkdownBullet",
      },

      pipe_table = {
        -- Turn on / off pipe table rendering
        enabled = true,
        -- Additional modes to render pipe tables
        render_modes = false,
        -- Pre configured settings largely for setting table border easier
        --  heavy:  use thicker border characters
        --  double: use double line border characters
        --  round:  use round border corners
        --  none:   does nothing
        preset = "round",
        -- Determines how the table as a whole is rendered:
        --  none:   disables all rendering
        --  normal: applies the 'cell' style rendering to each row of the table
        --  full:   normal + a top & bottom line that fill out the table when lengths match
        style = "full",
        -- Determines how individual cells of a table are rendered:
        --  overlay: writes completely over the table, removing conceal behavior and highlights
        --  raw:     replaces only the '|' characters in each row, leaving the cells unmodified
        --  padded:  raw + cells are padded to maximum visual width for each column
        --  trimmed: padded except empty space is subtracted from visual width calculation
        cell = "padded",
        -- Amount of space to put between cell contents and border
        padding = 1,
        -- Minimum column width to use for padded or trimmed cell
        min_width = 0,
        -- Characters used to replace table border
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
        -- stylua: ignore
        -- border = {
        --     '┌', '┬', '┐',
        --     '├', '┼', '┤',
        --     '└', '┴', '┘',
        --     '│', '─',
        -- },
        -- Gets placed in delimiter row for each column, position is based on alignment
        alignment_indicator = "━",
        -- Highlight for table heading, delimiter, and the line above
        head = "RenderMarkdownTableHead",
        -- Highlight for everything else, main table rows and the line below
        row = "RenderMarkdownTableRow",
        -- Highlight for inline padding used to add back concealed space
        filler = "RenderMarkdownTableFill",
      },
    })
  end,
}
