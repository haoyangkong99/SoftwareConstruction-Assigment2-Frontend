enum UserType { user, admin }

enum ChatMessageType { text, image, buyer_offer, seller_offer }

enum ChatType { buying, selling }

enum VisibilityType { allow, disallow }

enum AddressType { home, workplace, unfilled }

enum ItemStatus { to_start, in_progress, completed, deleted }

enum Gender { Male, Female }

enum OfferStatus { pending, accepted, rejected }

enum OrderStatus { in_progress, completed, cancelled }

enum PaymentType { cash_on_delivery, card, self_arrange }

enum PaymentStatus { successful, failed }

enum MalaysiaBank {
  AFFIN_BANK_BHD,
  ALLIANCE_BANK_MALAYSIA_BHD,
  AMBANK_BHD,
  BANK_ISLAM_MALAYSIA_BHD,
  BANK_RAKYAT,
  BANK_SIMPANAN_NASIONAL_BHD,
  CIMB_BANK_BHD,
  CITIBANK_BHD,
  HONG_LEONG_BANK_BHD,
  HSBC_BANK_MALAYSIA_BHD,
  MAYBANK,
  MBSB_BANK,
  OCBC_AL_ALMIN_BANK_BHD,
  PUBLIC_BANK_BHD,
  RHB_BANK_BHD,
  STANDARD_CHARTERED_BANK_BHD,
  UNITED_OVERSEAS_BANK_MALAYSIA_BHD
}
