using Godot;
using System;

public partial class Player : CharacterBody2D
{
	private enum WeaponType { MELEE, GUN };
	private enum MoveMode { GROUND, WATER, SKY };
	private int _ammo { get; set; } = 8;
	private Node _data;
	// EXPORT VARIABLES
	[Export]
	private float _baseSpeed { get; set; } = 600.0f;
	[Export]
	private float _jumpSpeed { get; set; } = 5000.0f;
	[Export]
	private float _maxSpeed { get; set; } = 600.0f;
	[Export]
	private float _maxJump { get; set; } = 700.0f;
	[Export]
	public PackedScene Bullet { get; set; }
	[Signal]
	public delegate void AttackInputEventHandler();
	[Signal]
	public delegate void BulletFiredEventHandler();
	
	// PRIVATE VARIABLES
	//private int _currentWeapon = (int)WeaponType.MELEE;
	
	public float Gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();
	private float _direction = 1; // 1: right, -1: left
	private float _facing = 1; // Used to determine which way player is facing, also used for bullets
	private float _vertical = 0; // 1: looking up, -1: looking down; this is used for aiming attacks
	private bool _isAttackingDown = false;
	
	// STATES
	private bool _attackState = false;
	private bool _duckState = false;
	private bool _jumpState = false; // Used so the player can hold the jump button to jump higher
	
	private void Init() {
		GD.Print("initializing player. . .");
		GetNode<CollisionShape2D>("DuckCollision").Hide();
		GD.Print("player initialization complete");
	}
	
	private void FireBullet() {
		// SANITY CHECK IN CASE PLAYER SOMEHOW FIRES WITHOUT BULLETS
		//if(_ammo <= 0) { // Preferably, this should not be called in normal play
		if((int)this._data.Get("current_ammo") <= 0) {
			GD.Print("can't fire: out of ammo");
			_attackState = false;
			return;
		}
		// FIRE THE BULLET
		this._data.Set("current_ammo", (int)this._data.Get("current_ammo") - 1);
		EmitSignal(SignalName.BulletFired, (int)_data.Get("current_ammo"));
		var bullet = Bullet.Instantiate();
		Vector2 bullet_pos;
		if(_duckState || _vertical == -1)
			bullet_pos = GetNode<Marker2D>("BulletSpawnDown").Position;
		else
			bullet_pos = GetNode<Marker2D>("BulletSpawnUp").Position;
		AddChild(bullet);
		bullet.Call("init", bullet_pos, _facing, _vertical);
		GetNode<Timer>("BulletCooldown").Start();
		if(_duckState == false && _vertical == -1)
			_isAttackingDown = true;
		if((int)this._data.Get("current_ammo") <= 0) // auto-swap to melee once player runs out of ammo
			this._data.Call("swap_weapon");
	}
	
	public override void _Ready() {
		this._data = GetNode<Node>("PlayerData"); // assign the player node to a variable for reuse
		// TO-DO: get other game data
		Init();
	}
	
	public override void _Process(double delta) {
		// WEAPON SWAP HANDLING
		if (Input.IsActionJustPressed("swap_weapon")) {
			this._data.Call("swap_weapon");
		}
		// ATTACK HANDLING
			// TO-DO: add Psyonic behavior
		if (Input.IsActionJustPressed("cancel") && !_attackState) {
			this.AttackHandling();
		}
	}
	
	private void AttackHandling() {
			_attackState = true;
			int current_weapon = (int)this._data.Get("current_weapon");
			if(current_weapon == 0) {
				//GD.Print(_facing, " + ", _duckState, " + ", _vertical);
				if(_duckState == false && _vertical == -1)
					_isAttackingDown = true;
				EmitSignal(SignalName.AttackInput, _facing, _duckState, _vertical);
				}
			else if(current_weapon == 1)
				FireBullet();
	}
	
	// INPUT PROCESSING; might abstract some of this?
	public override void _PhysicsProcess(double delta) {
		Vector2 velocity = Velocity;
		velocity.Y += Gravity * (float)delta;
		// JUMP HANDLING
		if (Input.IsActionPressed("confirm") && !_jumpState) {
			velocity.Y += -_jumpSpeed * (float)delta;
			if(velocity.Y <= -_maxJump) {
				velocity.Y = -_maxJump;
				_jumpState = true;
			}
		} else if (IsOnFloor()) {
			_jumpState = false;
		} else if (!IsOnFloor()) {
			_jumpState = true;
		}
		// DUCK HANDLING
		if (Input.IsActionPressed("move_down") && IsOnFloor()) {
			_duckState = true;
		} else
			_duckState = false;
		// GET INPUT DIRECTION
		_direction = Input.GetAxis("move_left", "move_right"); // left = -1, right = 1
		//if(_duckState)
		//	_direction = 0; // don't allow for left or right input if ducking
		if(!_attackState) {
			if(_duckState) {
				GetNode<CollisionShape2D>("NormalCollision").Hide();
				GetNode<CollisionShape2D>("DuckCollision").Show();
			}
			else {
				//_direction = Input.GetAxis("move_left", "move_right"); // left = -1, right = 1
				GetNode<CollisionShape2D>("DuckCollision").Hide();
				GetNode<CollisionShape2D>("NormalCollision").Show();
			}
		}
		if(IsOnFloor() && _attackState && _isAttackingDown) { // If attacking down, cease attack once landing
			_attackState = false;
			_isAttackingDown = false;
		}
		_vertical = Input.GetAxis("move_down", "move_up"); // down = -1, up = 1
		if(IsOnFloor() && _vertical == -1) // Can only aim down if in the air
			_vertical = 0;
		if(Input.IsActionPressed("move_up") && _duckState)
			_vertical = 1;
		// HANDLE MOVEMENT (this is coded like shit but whatever)
		//velocity.X += _direction * _baseSpeed * (float)delta;
		velocity.X += _direction * _baseSpeed * (float)delta;
		if(_direction == 0 || _duckState) { // If not moving, make player stop
			if(velocity.X > 0)
				velocity.X = Mathf.Clamp(velocity.X - ((_maxSpeed * 2) * (float)delta), 0, _maxSpeed);
			else
				velocity.X = Mathf.Clamp(velocity.X + ((_maxSpeed * 2) * (float)delta), -_maxSpeed, 0);
		} else {
			if(_direction == 1 && velocity.X < 0)
				velocity.X = Mathf.Clamp(velocity.X + ((_maxSpeed * 2) * (float)delta), -_maxSpeed, _maxSpeed);
			else if (_direction == -1 && velocity.X > 0)
				velocity.X = Mathf.Clamp(velocity.X - ((_maxSpeed * 2) * (float)delta), -_maxSpeed, _maxSpeed);
		}
		velocity.X = Mathf.Clamp(velocity.X, -_maxSpeed, _maxSpeed); // make sure speed doesn't go beyond max
		if(!_attackState) {
			//if(velocity.X != 0 && _direction != 0) {
			if(_direction != 0) {
				GetNode<AnimatedSprite2D>("AnimatedSprite2D").FlipH = _direction < 0;
				_facing = _direction;
			}
		}
		// MOVE CHARACTER
		Velocity = velocity;
		MoveAndSlide();
	}
	
	private void _on_sword_attack_finished() {
		_attackState = false;
		_isAttackingDown = false;
	}
	
	private void _on_bullet_cooldown_timeout() {
		_attackState = false;
		_isAttackingDown = false;
	}
}
