module Slack
  # This module handles Slack slash commands.
  module Commands

    def self.whois(params, trigger_id)
      case params
      when /<@([^|]+).*>/
        Slack::Actions.async_view_profile(trigger_id, $1)
      else
        [
          'Désolé, je ne sais pas de qui tu parles ... :confused:',
          'Je ne connais pas cette personne  :face_with_monocle:',
          'Qui-est-ce ? Moi je ne sais pas ... :thinking_face:'
        ].sample
      end
    end

    def self.print_unknown_command
      [
        'Je ne connais pas cette commande :confused:',
        'Désolé, pas compris :face_with_monocle:',
        'Essaye encore, parce que là je ne sais pas quoi te dire :thinking_face:'
      ].sample
    end

    def self.print_help
%(
*Bonjour, je suis Corbot, un assistant pensé pour faciliter la vie des encordés*.

Il y a plusieurs façons de m'utiliser :
- *Ajouter moi à tes applications* (le bouton + tout en bas de la barre latérale) pour savoir qui est présent à la Cordée
- Tu peux *voir le profil d'un membre* qui vient d'écrire sur Slack en cliquant sur le *bouton "..."* de son message puis sur "Voir le profil du membre"
- Tu peux aussi *lancer l'une des commandes suivantes* :
    - `/corbot help` : affiche cette aide
    - `/corbot whois @christian` : affiche le profil d'un membre à partir de son identifiant Slack
)
    end
  end
end