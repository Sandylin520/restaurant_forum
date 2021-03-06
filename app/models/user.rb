class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name
  mount_uploader :avatar, AvatarUploader

  def admin?
    self.role == "admin"
  end
  #用 self 呼叫物件自己，而 self.role == "admin" 是一行陳述，如果 role 屬性等於 "admin"，該陳述就會回傳 True，否則將回傳 False。

# 「使用者評論很多餐廳」的多對多關聯
  has_many :comments, dependent: :restrict_with_error   # 如果 User 已經有了評論，就不允許刪除帳號（刪除時拋出 Error）
  has_many :commented_restaurants, through: :comments, source: :restaurant

# 「使用者收藏很多餐廳」的多對多關聯
  # 「使用者收藏很多餐廳」的多對多關聯
  # 由於使用 restaurants 會和「使用者評論很多餐廳」重覆，將關聯名稱自訂為 :favorited_restaurants
  # 自訂名稱後，Rails 無法自動推論來源名稱，需另加 source 告知 model name
  has_many :favorites, dependent: :destroy
  has_many :favorited_restaurants, through: :favorites, source: :restaurant

# 「使用者追蹤使用者」的 self-referential relationships 設定
# 不需要另加 source，Rails 可從 Followship Model 設定來判斷 followings 指向 User Model
  has_many :followships, dependent: :destroy #先在 followships 上找出一整列的追蹤紀錄
  has_many :followings, through: :followships #再從追蹤紀錄查出個別欄位(user_id)，按外鍵名稱回到 users 上依序取出使用者

#「使用者的追蹤者」的設定
 # 透過 class_name, foreign_key 的自訂，指向 Followship 表上的另一側
 has_many :inverse_followships, class_name: "Followship", foreign_key: "following_id" #先在 followships 上找出一整列的追蹤紀錄
 has_many :followers, through: :inverse_followships, source: :user#有了前面追蹤紀錄、following_id，再從追蹤紀錄上找user_id欄位，按外鍵名稱回到 users 上依序取出使用者

#使用者有很多朋友的多對多關聯
 has_many :friendships, class_name: "Friendship", primary_key: "id", foreign_key: "user_id", dependent: :destroy
 #destroy 代表的是當刪除user, 該user擁有的friendship會一起刪除
 has_many :friends, through: :friendships

 #加使用者好友的人
  has_many :inverse_friendships, class_name: "Friendship", primary_key: "id", foreign_key: "friend_id"  #找出friendship中使用者被設為friend_id的追蹤紀錄
  has_many :inverse_friends, through: :inverse_friendships, source: :user



  def following?(user)
    self.followings.include?(user) #self 來代表 instance 本身，並使用關聯方法 self.favorited_users 查出該餐廳物件相關的所有 User 紀錄。
  end

  def friend?(user)
    self.friends.include?(user)
  end


end
