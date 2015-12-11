#!/usr/bin/env ruby

tags_to_delete = `git tag`.split(/\s+/).select { |tag| !tag.start_with?('emp') }

# delete local tag
`git tag -d #{tags_to_delete.join ' '}`
# delete remote tag
`git push origin #{tags_to_delete.map { |t| ":refs/tags/#{t}" }.join ' '}`
