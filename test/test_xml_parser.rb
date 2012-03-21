require 'helpers'

describe "MusicStory::XMLParser" do

  # reasonably comprehensive end-to-end test which should cover all the essentials
  # of what's a fairly mechanical data conversion:
  it "should correctly parse artists in a test XML file" do
    filename = File.join(File.dirname(__FILE__), 'test-data.xml')

    artists = []
    MusicStory::XMLParser.each_in_file(filename) do |artist|
      artists << artist
    end

    assert_equal 1, artists.length
    artist = artists.first
    assert_kind_of MusicStory::Artist, artist

    assert_equal 42, artist.id
    assert_equal 'Serge Gainsbourg', artist.name
    assert_equal 'Serge', artist.forename
    assert_equal 'Lucien Ginsburg', artist.real_name
    assert_equal 'Compositeur', artist.role
    assert_equal 'artiste', artist.type
    assert_equal 'France', artist.country
    summary = <<-END
Rive gauche

Issu d'une famille d'émigrés juifs Russes installés à Paris en 1921, Lucien Ginsburg est élevé dans la religion des arts, en particulier la musique classique que son père, pianiste de music-hall, joue pendant des heures à la maison. Après la guerre, passée sous le signe de l'exil de la peur de ceux marqués par la « yellow star », il veut devenir peintre mais, par nécessité alimentaire et impulsion paternelle, se retrouve dans les cabarets comme guitariste-pianiste.

En 1954, c'est le début des saisons d'été Chez Flavio au Touquet et des nuits au Milord l'Arsouille, Lucien Ginsburg dépose ses premiers titres à la SACEM , à partir de 57, ils le seront sous le nom de Serge Gainsbourg et commenceront à être interprétés par sa patronne Michèle Arnaud. 1958, le patron du Milord, Françis Claude, lui fait ses premiers pas sur scène. Repéré par le label Philips, il entre en studio et commence sa fructueuse association avec Alain Goraguer déjà arrangeur de Boris Vian. C'est le premier succès avec « Le poinçonneur des Lilas », il entre vraiment dans la profession, part en tournée avec Jacques Brel et, supporté par Boris Vian, rencontre Juliette Gréco. Débute une collaboration qui durera tout au long de cette période « rive gauche » dont le point d'orgue sera « La javanaise » à l'automne 62.

Succès yé-yé

Albums, tournées, se succèdent. Sur scène, son hyper-sensibilité morgue et son physique particulier provoquent souvent des réactions de rejet. En coulisse toutefois, il est déjà un explorateur assidu du continent féminin et en tirera ses meilleurs textes. Mais son style, littéraire, sombre et très appliqué, commence à dater, l'heure n'est plus aux cabarets. Gainsbourg donne dans l'avant-garde et le jazz sur l'album Confidentiel (1963) puis dans les rythmes exotiques sur Gainsbourg Percussions (64) le changement est là ... mais le succès non. Celui-ci, quasiment prémédité, va venir de sa collaboration avec la chanteuse France Gall et « Poupée de cire poupée de son » qui remporte le Concours de l'Eurovision en 1965. La projection que Gainsbourg fait de ses textes à double-sens sur l'image enfantine de France Gall crée le décalage (Lolita déjà...), le sommet étant atteint avec « Les sucettes » en 66.

Argent, nouveaux interprètes, nouvelle période, certainement la plus mature, intense et créative. C'est la pop et les comics, les Beatles dominent la planète et à la télé Serge multiplie ses apparitions, notamment dans le Sacha Show de Distel. Avec Michel Colombier, son nouvel arrangeur, Serge va parfaitement être dans la pulsation de l'époque et va chercher le son de la pop anglaise au c?ur du Swinging London. On notera entre autres « Comic Strip » (1967) mixé par Georgio Gomelski, la B.O. du film Le Pacha, véritable beat samplé avant l'heure (68), « Elisa » (69). En 1968 un événement va bouleverser et transcender sa production : sa brève mais intense histoire d'amour avec Brigitte Bardot, star mondiale à l'époque. C'est la sortie de « Bonnie and Clyde », l'enregistrement de « Je t'aime moi non plus » juste avant leur rupture. (titre dont Bardot bloque la sortie par peur pour sa carrière) et enfin l'hommage Baudelaurien et baroque de « Initials B.B. ».

Les années Birkin

Suit sur le tournage de Slogan, l'autre rencontre : Jane Birkin, anglaise, très jeune mère déjà séparée de son premier mari John Barry, et dont Gainsbourg devient le Pygmalion . La sortie ré-enregistrée avec Jane de « Je t'aime moi non plus » va faire à la fois un scandale et un tube mondial. En 1971 sort l'avant-gardiste Histoire de Melody Nelson fruit de sa collaboration avec Jean-Claude Vannier. Chef-d'?uvre baroque, symbolique, concentrant la pop la plus aboutie et les orchestrations classiques.

Jusqu'à L'Homme à Tête de Chou en 1976, et à l'exception de Vu de l'Extérieur (1973), Gainsbourg explorera cette veine du concept-album, notamment avec règlement de compte provocateur avec ses années de guerre sur Rock Around the Bunker, album encore injustement évité aujourd'hui. Il enchaîne ensuite une série très alimentaire de tubes de l'été, de « L'ami caouette » (1975) à « Sea Sex and Sun » (1978).

A nouveau en décalage avec l'air du temps (entre temps les punk ont débarqués), il réapparaît sur scène lors d'une collaboration avec le groupe Bijou, puis trouve une nouvelle veine qui va le faire à nouveau, et même plus que jamais auparavant, entrer en résonance avec son époque : le reggae. Il enregistre avec Robbie Shakespeare et Sly Dunbar à Kingston deux albums Aux Armes et caetera (1979) puis Mauvaises Nouvelles des Etoiles\302\240 (1981). Le succès est énorme, doublé de polémiques liés à sa reprise de l'ymne national «La Marseillaise ».

Gainsbarre

Mais en 1980 Gainsbourg-Birkin c'est fini, et ces albums introduisent un nouveau personnage : Gainsbarre (« Ecce homo »), personnage auto-destructeur et vulgaire. Gainsbourg a trouvé son ultime carapace, sa sensibilité à fleur de peau sera dorénavant cachée sous les provocations médiatiques. Pour ses deux derniers albums, Love on the Beat (1984) et You're Under Arrest (1987), Gainsbarre saura encore bien utiliser les pointures funk-rock du moment, mais la re-dite n'est pas loin. On se souviendra davantage de l'extraordinaire engouement de la jeunesse pour ses concerts, qui, du coup, pouvaient retrouver des sommets d'émotion, tant cet accueil le touchait.

Gainsbourg meurt le 2 mars 1991 d'un arrêt cardiaque à l'âge de 62 ans, « tué par Gainsbarre pour se venger de l'avoir créé » (Charles Trenet). Les collaborations réussies de son vivant sont innombrables. Les années 1990 verront son influence grandir encore, notamment dans le monde anglo-saxon. Son génie pour l'évocation d'émotions fugaces, sous-tendues par une maîtrise étonnante dans l'utilisation du meilleur des musiques populaires, font de lui un des phares de la chanson française du XXème siècle.

Héritage

Début 2010, le film Gainsbourg (Vie héroïque) réalisé par le dessinateur Joann Sfar met l'artiste à l'honneur sur grand écran. L'acteur principal qui a la lourde tache d'incarner le mythe, Eric Elmosnino, est entouré de Laetitia Casta (Brigitte Bardot), Lucy Gordon (Jane Birkin), Anna Mouglalis (Juliette Gréco) et Philippe Katerine (Boris Vian). Le film remporte trois trophées, dont celui du meilleur acteur, lors de la cérémonie des Césars le 25 février 2011. Au même moment, le vingtième anniversaire de la disparition de l'homme à tête de chou est célébré en grandes pompes avec la découverte de la version originale de « Comme un boomerang » (1975) et la parution d'une troisième Intégrale en 20 CD et 284 titres dont 14 inédits.
END
    assert_equal summary.strip, artist.plain_text_summary
    bio = <<-END
Rive gauche

Issu d'une famille d'émigrés juifs Russes installés à Paris en 1921, Lucien Ginsburg est élevé dans la religion des arts, en particulier la musique classique que son père, pianiste de music-hall, joue pendant des heures à la maison. Après la guerre, passée sous le signe de l'exil de la peur de ceux marqués par la « yellow star », il veut devenir peintre mais, par nécessité alimentaire et impulsion paternelle, se retrouve dans les cabarets comme guitariste-pianiste.

En 1954, c'est le début des saisons d'été Chez Flavio au Touquet et des nuits au Milord l'Arsouille, Lucien Ginsburg dépose ses premiers titres à la SACEM , à partir de 57, ils le seront sous le nom de Serge Gainsbourg et commenceront à être interprétés par sa patronne Michèle Arnaud. 1958, le patron du Milord, Françis Claude, lui fait ses premiers pas sur scène. Repéré par le label Philips, il entre en studio et commence sa fructueuse association avec Alain Goraguer déjà arrangeur de Boris Vian. C'est le premier succès avec « Le poinçonneur des Lilas », il entre vraiment dans la profession, part en tournée avec Jacques Brel et, supporté par Boris Vian, rencontre Juliette Gréco. Débute une collaboration qui durera tout au long de cette période « rive gauche » dont le point d'orgue sera « La javanaise » à l'automne 62.

Succès yé-yé

Albums, tournées, se succèdent. Sur scène, son hyper-sensibilité morgue et son physique particulier provoquent souvent des réactions de rejet. En coulisse toutefois, il est déjà un explorateur assidu du continent féminin et en tirera ses meilleurs textes. Mais son style, littéraire, sombre et très appliqué, commence à dater, l'heure n'est plus aux cabarets. Gainsbourg donne dans l'avant-garde et le jazz sur l'album Confidentiel (1963) puis dans les rythmes exotiques sur Gainsbourg Percussions (64) le changement est là ... mais le succès non. Celui-ci, quasiment prémédité, va venir de sa collaboration avec la chanteuse France Gall et « Poupée de cire poupée de son » qui remporte le Concours de l'Eurovision en 1965. La projection que Gainsbourg fait de ses textes à double-sens sur l'image enfantine de France Gall crée le décalage (Lolita déjà...), le sommet étant atteint avec « Les sucettes » en 66.

Argent, nouveaux interprètes, nouvelle période, certainement la plus mature, intense et créative. C'est la pop et les comics, les Beatles dominent la planète et à la télé Serge multiplie ses apparitions, notamment dans le Sacha Show de Distel. Avec Michel Colombier, son nouvel arrangeur, Serge va parfaitement être dans la pulsation de l'époque et va chercher le son de la pop anglaise au c?ur du Swinging London. On notera entre autres « Comic Strip » (1967) mixé par Georgio Gomelski, la B.O. du film Le Pacha, véritable beat samplé avant l'heure (68), « Elisa » (69). En 1968 un événement va bouleverser et transcender sa production : sa brève mais intense histoire d'amour avec Brigitte Bardot, star mondiale à l'époque. C'est la sortie de « Bonnie and Clyde », l'enregistrement de « Je t'aime moi non plus » juste avant leur rupture. (titre dont Bardot bloque la sortie par peur pour sa carrière) et enfin l'hommage Baudelaurien et baroque de « Initials B.B. ».

Les années Birkin

Suit sur le tournage de Slogan, l'autre rencontre : Jane Birkin, anglaise, très jeune mère déjà séparée de son premier mari John Barry, et dont Gainsbourg devient le Pygmalion . La sortie ré-enregistrée avec Jane de « Je t'aime moi non plus » va faire à la fois un scandale et un tube mondial. En 1971 sort l'avant-gardiste Histoire de Melody Nelson fruit de sa collaboration avec Jean-Claude Vannier. Chef-d'?uvre baroque, symbolique, concentrant la pop la plus aboutie et les orchestrations classiques.

Jusqu'à L'Homme à Tête de Chou en 1976, et à l'exception de Vu de l'Extérieur (1973), Gainsbourg explorera cette veine du concept-album, notamment avec règlement de compte provocateur avec ses années de guerre sur Rock Around the Bunker, album encore injustement évité aujourd'hui. Il enchaîne ensuite une série très alimentaire de tubes de l'été, de « L'ami caouette » (1975) à « Sea Sex and Sun » (1978).

A nouveau en décalage avec l'air du temps (entre temps les punk ont débarqués), il réapparaît sur scène lors d'une collaboration avec le groupe Bijou, puis trouve une nouvelle veine qui va le faire à nouveau, et même plus que jamais auparavant, entrer en résonance avec son époque : le reggae. Il enregistre avec Robbie Shakespeare et Sly Dunbar à Kingston deux albums Aux Armes et caetera (1979) puis Mauvaises Nouvelles des Etoiles\302\240 (1981). Le succès est énorme, doublé de polémiques liés à sa reprise de l'ymne national «La Marseillaise ».

Gainsbarre

Mais en 1980 Gainsbourg-Birkin c'est fini, et ces albums introduisent un nouveau personnage : Gainsbarre (« Ecce homo »), personnage auto-destructeur et vulgaire. Gainsbourg a trouvé son ultime carapace, sa sensibilité à fleur de peau sera dorénavant cachée sous les provocations médiatiques. Pour ses deux derniers albums, Love on the Beat (1984) et You're Under Arrest (1987), Gainsbarre saura encore bien utiliser les pointures funk-rock du moment, mais la re-dite n'est pas loin. On se souviendra davantage de l'extraordinaire engouement de la jeunesse pour ses concerts, qui, du coup, pouvaient retrouver des sommets d'émotion, tant cet accueil le touchait.

Gainsbourg meurt le 2 mars 1991 d'un arrêt cardiaque à l'âge de 62 ans, « tué par Gainsbarre pour se venger de l'avoir créé » (Charles Trenet). Les collaborations réussies de son vivant sont innombrables. Les années 1990 verront son influence grandir encore, notamment dans le monde anglo-saxon. Son génie pour l'évocation d'émotions fugaces, sous-tendues par une maîtrise étonnante dans l'utilisation du meilleur des musiques populaires, font de lui un des phares de la chanson française du XXème siècle.

Héritage

Début 2010, le film Gainsbourg (Vie héroïque) réalisé par le dessinateur Joann Sfar met l'artiste à l'honneur sur grand écran. L'acteur principal qui a la lourde tache d'incarner le mythe, Eric Elmosnino, est entouré de Laetitia Casta (Brigitte Bardot), Lucy Gordon (Jane Birkin), Anna Mouglalis (Juliette Gréco) et Philippe Katerine (Boris Vian). Le film remporte trois trophées, dont celui du meilleur acteur, lors de la cérémonie des Césars le 25 février 2011. Au même moment, le vingtième anniversaire de la disparition de l'homme à tête de chou est célébré en grandes pompes avec la découverte de la version originale de « Comme un boomerang » (1975) et la parution d'une troisième Intégrale en 20 CD et 284 titres dont 14 inédits.

 Copyright 2012 Music Story
END
    assert_equal bio.strip, artist.plain_text_bio

    artist.all_genres.each {|g| assert_kind_of MusicStory::Genre, g}
    artist.genre_relations.each {|t,g| assert_kind_of Symbol, t; assert_kind_of MusicStory::Genre, g}
    assert_equal [5, 24, 1, 25, 21, 26, 27, 28, 29, 42, 71, 151, 72, 216, 99], artist.all_genres.map(&:id)
    assert_equal ["Pop", "Chanson française", "Rock", "Reggae", "Jazz", "Funk", "Rap", "Musique classique", "Rive gauche", "Yéyé", "Pop française", "Musiques du monde", "Rock français", "Comédie Musicale", "Chanson engagée"], artist.all_genres.map(&:name)
    assert_equal [:secondary, :main, :influenced_by, :secondary, :secondary, :influenced_by, :influenced_by, :influenced_by, :main, :influenced_by, :main, :influenced_by, :main, :secondary, :secondary], artist.genre_relations.map {|t,g| t}

    artist.all_associated_artists.each {|a| assert_kind_of MusicStory::Artist, a}
    assert_equal [176, 806, 746, 1777, 1422, 1218, 747, 1663, 555, 100110], artist.all_associated_artists.map(&:id)
    assert_equal ["Boris Vian", "Alain Bashung", "Fréhel", "Arthur H", "Daniel Darc", "Benjamin Biolay", "Léo Ferré", "Katerine", "Little Richard", "The Moody Blues"], artist.all_associated_artists.map(&:name)
    assert_equal [:influenced_by, :successor, :influenced_by, :successor, :successor, :successor, :similar, :similar, :similar, :similar], artist.associations.map {|t,a| t}
  end
end