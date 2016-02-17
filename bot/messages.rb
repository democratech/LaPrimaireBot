# encoding: utf-8
NAME="La Primaire"
BOTNAME="Victoire"

# For the list of unicode code for emoticons see : http://apps.timwhitlock.info/emoji/tables/unicode
EMOTICONS={
	:blush=>"\u{1F60A}",
	:crying_face=>"\u{1F622}",
	:face_sunglasses=>"\u{1F60E}",
	:megaphone=>"\u{1F4E3}",
	:memo=>"\u{1F4DD}",
	:speech_balloon=>"\u{1F4AC}",
	:finger_up=>"\u{261D}",
	:french_flag=>"\u{1F1EB}",
	:finger_right=>"\u{1F449}",
	:house=>"\u{1F3E0}",
	:thumbs_up=>"\u{1F44D}",
	:thumbs_down=>"\u{1F44E}",
	:search=>"\u{1F50D}",
	:disappointed=>"\u{1F629}"
}

WELCOME= <<-WELCOME
Bonjour %{first_name} !
Je suis #{BOTNAME}, votre guide pour #{NAME} #{EMOTICONS[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons !
WELCOME

HOME= <<-AUTH
Que voulez-vous faire ?
AUTH

YOU_CANDIDAT= <<-END
Qui souhaitez-vous proposer comme candidat(e) ?
END

YOU_CANDIDAT_CONFIRM= <<-END
Ok, je recherche...
%{media}
Est-ce bien votre choix ?
END

YOU_CANDIDAT_YES= <<-END
Parfait, c'est bien enregistré !
END

YOU_CANDIDAT_NO= <<-END
Hmmmm... réessayons !
END

YOU_CANDIDAT_NOT_FOUND= <<-END
Malheureusement, je ne trouve personne avec ce nom #{EMOTICONS[:crying_face]}
END

NOT_IMPLEMENTED= <<-PARTI
Désolée, je n'ai pas encore reçu les instructions pour vous guider dans ce choix #{EMOTICONS[:crying_face]}
PARTI

PAS_COMPRIS= <<-PAS_COMPRIS
Aïe, désolé %{first_name} j'ai peur de ne pas avoir compris ce que vous me demandez #{EMOTICONS[:crying_face]}
PAS_COMPRIS

