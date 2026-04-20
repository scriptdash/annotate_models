require_relative '../../../spec_helper'
require 'annotate/annotate_models'

describe AnnotateModels do
  describe '.annotate_pattern' do
    subject(:pattern) { described_class.annotate_pattern(options) }

    let(:options) { {} }

    context 'without wrapper' do
      it 'matches a schema annotation block using == prefix' do
        text = "# == Schema Info\n#  id :integer\n"
        expect(text).to match(pattern)
      end

      it 'matches a schema annotation block using ## prefix' do
        text = "# ## Schema Info\n#  id :integer\n"
        expect(text).to match(pattern)
      end

      it 'does not match a YARD tag line in isolation' do
        expect("# @owners { team: payments }\n").not_to match(pattern)
      end

      it 'stops matching before a YARD tag line' do
        text = "# == Schema Info\n#  id :integer\n# @owners { team: payments }\n"
        expect(text.match(pattern)[0]).not_to include('@owners')
      end

      it 'preserves YARD tags when stripping annotation from file content' do
        content = "# == Schema Info\n#  id :integer\n# @owners { team: payments }\nclass User; end\n"
        stripped = content.gsub(pattern, '')
        expect(stripped).to include('# @owners { team: payments }')
        expect(stripped).not_to include('== Schema Info')
      end

      it 'removes schema lines that do not contain YARD tags' do
        content = "# == Schema Info\n#  id :integer\n#  name :string\nclass User; end\n"
        stripped = content.gsub(pattern, '')
        expect(stripped).not_to include('== Schema Info')
        expect(stripped).not_to include('#  id')
        expect(stripped).not_to include('#  name')
      end

      it 'still strips schema lines that contain @ mid-line (e.g. a column comment)' do
        # `@` only triggers the YARD tag guard when it appears right after `#` with
        # only optional whitespace between them -- not when buried in the line.
        content = "# == Schema Info\n#  role :string   # @admin only\nclass User; end\n"
        stripped = content.gsub(pattern, '')
        expect(stripped).not_to include('== Schema Info')
        expect(stripped).not_to include('#  role')
      end
    end

    context 'with wrapper_open option' do
      let(:options) { { wrapper_open: 'START' } }

      it 'matches a schema annotation block with wrapper' do
        text = "# START\n# == Schema Info\n#  id :integer\n"
        expect(text).to match(pattern)
      end

      it 'preserves YARD tags when stripping annotation with wrapper' do
        content = "# START\n# == Schema Info\n#  id :integer\n# @owners { team: payments }\nclass User; end\n"
        stripped = content.gsub(pattern, '')
        expect(stripped).to include('# @owners { team: payments }')
        expect(stripped).not_to include('== Schema Info')
      end
    end
  end
end
