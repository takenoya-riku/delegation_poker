# Services

このディレクトリには、ビジネスロジックを実装するServiceクラスが含まれています。

## ディレクトリ構造

```
app/services/
└── concerns/
    └── service.rb          # Serviceモジュール（concern）
```

## Serviceクラスの作成ルール

### 1. Serviceクラスの実装

- **必ず`Service`モジュールを`include`する**
- **`call`メソッドをインスタンスメソッドとして実装する**
- ビジネスロジックのみを実装する（認証認可・データ取得は呼び出し側で行う）

```ruby
class CreateRoomService
  include Service

  def call(name:)
    room = Room.new(name: name)

    if room.save
      OpenStruct.new(success: true, room: room, errors: [])
    else
      OpenStruct.new(success: false, room: room, errors: room.errors.full_messages)
    end
  end
end
```

### 2. Serviceクラスの呼び出し

- **必ず`call`メソッドで呼び出す**
- クラスメソッドとして`ServiceClass.call(...)`で呼び出す

```ruby
# GraphQL MutationやResolverでの使用例
def resolve(name:)
  # TODO: 認証認可の実装
  # authorize! :create, Room

  result = CreateRoomService.call(name: name)

  {
    room: result.room,
    errors: result.errors
  }
end
```

### 3. Serviceモジュールの機能

`Service`モジュール（`app/services/concerns/service.rb`）は以下の機能を提供します：

- **`call`クラスメソッド**: `new.call(**kwargs)`として実装され、インスタンスを作成して`call`メソッドを呼び出す
- **`logger`メソッド**: `Rails.logger`へのアクセスを提供

## 設計原則

- **Resolver/Mutationは薄い層**: 認証認可・serviceクラスの呼び出し・簡単なデータ取得のみ
- **ビジネスロジックはServiceクラスに集約**: 複雑な処理はすべてServiceクラスに実装
- **Serviceクラスは必ず`call`で呼び出し可能**: `ServiceClass.call(...)`の形式で統一
