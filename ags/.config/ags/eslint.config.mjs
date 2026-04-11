import eslint from '@eslint/js'
import tsParser from '@typescript-eslint/parser'
import { defineConfig } from 'eslint/config'
import { importX } from 'eslint-plugin-import-x'
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended'
import { configs } from 'typescript-eslint'

export default defineConfig(
  eslint.configs.recommended,
  configs.strict,
  configs.stylistic,
  importX.flatConfigs.recommended,
  importX.flatConfigs.typescript,
  {
    files: ['**/*.{mjs,ts,tsx}'],
    languageOptions: {
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
      parser: tsParser,
      ecmaVersion: 'latest',
      sourceType: 'module',
    },
    plugins: {
      'import-x': importX,
    },
    extends: ['import-x/flat/recommended'],
    rules: {
      'import-x/default': 'warn',
      'import-x/no-named-as-default-member': 'off',
      'import-x/no-unresolved': ['error', { ignore: ['^gi://'] }],
      'import-x/order': [
        'error',
        {
          groups: [
            'builtin',
            'external',
            ['sibling', 'parent'],
            'index',
            'type',
          ],
          'newlines-between': 'always',
          alphabetize: { order: 'asc', caseInsensitive: true },
        },
      ],
      'sort-imports': [
        'error',
        {
          ignoreCase: false,
          ignoreDeclarationSort: true,
          ignoreMemberSort: false,
          memberSyntaxSortOrder: ['none', 'all', 'multiple', 'single'],
          allowSeparatedGroups: true,
        },
      ],
    },
    settings: {
      'import-x/resolver': {
        typescript: true,
      },
    },
  },
  eslintPluginPrettierRecommended
)
