require "xmmsclient"
require "xmms2_utils/version"

module Xmms
    def self.decode_xmms2_url (url)
        URI.decode_www_form_component(url)
    end

    # Creates a new XMMS2 client and connects it to the server
    def self.client(name)
        xc = Xmms::Client.new(name)
        begin
            xc.connect()
        rescue Xmms::Client::ClientError => e
            $stderr.puts e
            `xmms2-launcher`
            ntries = 1
            while $? != 0
                if ntries > 4
                    exit "Can't start xmms2d. Exiting."
                end
                $stderr.puts "Coludn't start the daemon, trying again..."
                sleep 3
                `xmms2-launcher -vvvv`
                ntries += 1
            end
            xc.connect()
            $stderr.puts "Connected."
        end
        xc
    end
    class Client

        # Shuffles the playlist by selecting randomly among the tracks as
        # grouped by the given field
        #
        # shuffle_by is intended to change between different
        # artists/albums/genres more frequently than if all tracks were
        # shuffled based on a uniform distribution. In particular, it works
        # well at preventing one very large group of songs (like A. R.
        # Rahman's full discography) from dominating your playlist, but
        # leaves many such entries at the end of the playlist.
        def shuffle_by(playlist, field)
            pl = playlist.entries.wait.value
            artists = Hash.new
            rnd = Random.new
            playlist.clear.wait
            field = field.to_sym
            pl.each do |id|
                infos = self.medialib_get_info(id).wait.value
                a = infos[field].first[1]
                if artists.has_key?(a)
                    artists[a].insert(0,id)
                else
                    artists[a] = [id]
                end
            end

            artist_names = artists.keys
            for _ in pl
                artist_idx = (rnd.rand * artist_names.length).to_i
                artist = artist_names[artist_idx]
                songs = artists[artist]
                song_idx = rnd.rand * songs.length
                song = songs[song_idx]
                playlist.add_entry(song).wait
                songs.delete(song)
                if songs.empty?
                    artists.delete(artist)
                    artist_names.delete(artist)
                end
            end
        end

        # returns a hash of the passed in fields
        # with the first-found values for the fields
        def extract_medialib_info(id, *fields)
            infos = self.medialib_get_info(id).wait.value
            res = Hash.new
            if !infos.nil?
                fields = fields.map! {|f| f.to_sym }
                fields.each do |field|
                    values = infos[field]
                    if not values.nil?
                        my_value = values.first[1] # actual value from the top source [0]
                        if field == :url
                            my_value = Xmms::decode_xmms2_url(my_value)
                        end
                        res[field] = my_value.to_s.force_encoding("utf-8")
                    end
                end
            end
            res
        end
    end
end
