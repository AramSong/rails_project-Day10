# Day 10

* 중복 가입을 막는 방법

1. 가입버튼을 안보이게 한다.(사용자 화면 조작) -> Model 코딩(메서드)
2. 중복 가입 체크 후, 진행(서버에서 로직 조작)   -> Model 조건 추가(Model Validation)

* form_for 하나의 객체에 관련되서 진행한다.
*   <%= f.text_field :abcd ,value: "1234" %> value를 주면 가능하다.(의미없는 값)  field만 있는 경우엔 post에 해당 abcd column이 없기 때문에 오류가 나온다.
* 해당 모델이 갖고 있는 column과 text_field(input)창의 내용이 일치해야 한다.

`cafes_controller.rb`

```ruby
  def join_cafe
        #사용자가 가입하려는 까페
        cafe = Daum.find(params[:cafe_id])
        #현재 이 카페에 가입된 유저중에 지금 로그인한 유저가 있니?
        if cafe.is_member?(current_user)
            #가입 실패
            redirect_to :back, flash: {danger: "카페 가입에 실패했습니다."}
        else
            #가입 성공
             Membership.create(daum_id: params[:cafe_id],user_id: current_user.id)
             redirect_to :back, flash: {success: "카페 가입에 성공했습니다."}
        end
        #이 카페에 현재 로그인된 사용자가 가입이 됐는지
       
        #중복가입을 막는 방법
        # 1. 가입버튼을 안보이게 한다.(사용자 화면 조작) -> Model 코딩(메서드)
        # 2. 중복 가입 체크 후, 진행(서버에서 로직 조작) -> Model 조건 추가(Model Validation)
    end  
```



```ruby
#클래스 메소드   =>클래스를 바로 쓰느냐 
Daum.find(5)
#인스턴스 메소드 =>그걸로 만들어진 인스턴스를 쓰느냐
daum = Daum.find(5)
daum.title = ?
#클래스 메소드
def self.메소드명 --> 클래스 메소드
    로직안에서 self를 쓸 수 없음
end
#인스턴스 메소드
def 메소드명 --> 인스턴스 메소드
    로직안에서 self를 쓸 수 있음
end
-------------------------------------------------------------------------------------
    def is_member?(user) --> 매개변수
        self.users.include?(user)
    end
```

`cafes/show.html.erb` : 이미 가입된 멤버에게는 ''가입하기' 버튼이 뜨지 않는다.

```erb
  <% unless  @cafe.is_member?(current_user) %>
  <%= link_to "가입하기",join_cafe_path(@cafe),method:'post',class: "btn btn-primary"%>
  <% end %>
```

`membership.rb`

```ruby
class Membership < ApplicationRecord
    belongs_to :user
    belongs_to :daum
    # user_id와 daum_id가 unique해야함
    validates_uniqueness_of :user_id, scope: daum_id
    
end

```

* 모델코딩(인스턴스 메서드 만들기)

  * 모델코딩(user_name에 중복 불허 속성 주기)			--> `uniqueness :true`
  * uniqueness : 이 헬퍼는 객체가 저장되기 직전에 속성의 값이 고유하다는 것을 검증합니다.

  ``` ruby
  class Account < ApplicationRecord
    validates :email, uniqueness: true
  end
  ```

  유효성 검사는 모델의 테이블에 SQL 쿼리를 수행하여 해당 특성에서 동일한 값을 가진 기존 레코드를 검색하여 수행됩니다. 

  `:scope`고유성 검사를 제한하는 데 사용되는 하나 이상의 특성을 지정하는 데 사용할 수 있는 옵션이 있습니다.

   ```ruby
  class Holiday < ApplicationRecord
    validates :name, uniqueness: { scope: :year,
      message: "should happen once per year" }
  end
   ```

  `user.rb`

  ```ruby
  class User < ApplicationRecord
      has_secure_password
      #user_name 컬럼에 unique 속성 부여 
         validates   :user_name, uniqueness: true,
                              	 presence: true
      #presence는 빈 값을 허용하지 않는다.
         validates :password_digest, presence: true
      
      has_many    :memberships
      has_many    :daums, through: :memberships
      has_many    :posts
  end
  ```

  

* 모델코딩(클래스 메서드 만들기)

------

### 이미지 업로드

* `migrate/create_posts.rb`--> t.string :image_path 추가
* 파일 업로더 만들기

`_form.html.erb`

```erb
  <div class="field">
    <%= f.label :image_path %>
    <%= f.file_field :image_path, class: 'form-control'%>
  </div>
```

`posts_controller.rb`

```ruby
    def post_params
      params.require(:post).permit(:title, :contents, :daum_id,:image_path)
      #title: params[:post][:title],cafe_id:[:post][:cafe_id]
    end
```



* resize_to_fit : 큰쪽에 맞춰준다. 비율에 맞게 바꿔준다.
* resize_to_fill : 250,250을 맞춘 후남는 공간을 잘라버린다.
* whitelist : 지정된 확장자명만 허용하는 list를 만들어 준다.

`Gemfile`에  추가 

```ruby
#uploader
gem 'carrierwave'
gem 'mini_magick'
```



### AWS 연결하기

`Gemfile`에 추가

``` ruby
#credential 
gem 'figaro'
gem 'fog-aws'
```

`config/initializer/fog.rb`

```ruby
CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'                        # required
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     ENV["AWS_ACCESS_KEY_ID"],                        # required
    aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],                        # required
    region:                'ap-northeast-2',                  # optional, defaults to 'us-east-1'
    # host:                  's3.example.com',             # optional, defaults to nil
    endpoint:              'https://s3.ap-northeast-2.amazonaws.com' # optional, defaults to nil
  }
  config.fog_directory  = ENV["S3_BUCKET_NAME"]                                     # required
end
```

`application.yml`에access key id, secret access key, s3 bucket name 추가

