/*
 Hello world!
*/

#include "eth_util.angelscript"

int lastHit = 0;
bool dir = false;

bool moveLeft = true;
bool moveRight = true;

bool forwardLoop = true;
bool moving = false;
bool jumping = false;

bool ladder = false;

bool dead = false;

int shootTime = 0;

int shootStatus = 0;

int spriteFrame = 1;

void main()
{
	LoadScene("scenes/level1.esc", "Background", "");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void Background(){
	SetBackgroundColor(ARGB(255,255,255,255));
}

void HideT(){
	
	ETHEntityArray arrayT;
	GetEntityArray("wall.ent",arrayT);
	for(int i =0; i < arrayT.Size(); i++){
		arrayT[i].Hide(true);
	}
}

void UnhideT(){
	ETHEntityArray arrayT;
	GetEntityArray("wall.ent",arrayT);
	for(int i =0; i < arrayT.Size(); i++){
		arrayT[i].Hide(false);
	}
}
	
void ETHCallback_enemy(ETHEntity@ thisEntity){
	if(SeekEntity("char.ent") != null and distance(SeekEntity("char.ent").GetPositionXY(),thisEntity.GetPositionXY()) < 500)thisEntity.AddToPositionX(-2.0f);
	if(thisEntity.GetString("status") == "dead") DeleteEntity(thisEntity);
	}
	

void ETHCallback_char(ETHEntity@ thisEntity){
	if(dead)DeleteEntity(thisEntity);
	ETHPhysicsController@ controller = thisEntity.GetPhysicsController();
	ETHInput@ input = GetInputHandle();
	if(moving and GetTime() % 10 == 0 and !jumping and shootStatus == 0){
		if(forwardLoop)spriteFrame+= 1;
		if(!forwardLoop)spriteFrame-=1;
		if(spriteFrame == 1 or spriteFrame == 3)forwardLoop = !forwardLoop;
		thisEntity.SetSprite("entities/dudeWalker" + spriteFrame + ".png");
		moving = false;
	}
	else if(shootStatus != 0){
		if(shootStatus == 1){
			thisEntity.SetSprite("entities/dudeFiring1.png");
			shootStatus = 2;
			shootTime = GetTime();
		}
		else if(shootStatus == 2 and shootTime + 100 < GetTime()){
			thisEntity.SetSprite("entities/dudeFiring2.png");
			shootTime = GetTime();
			shootStatus = 3;
		}
		else if(shootStatus == 3 and shootTime + 200 < GetTime()){
			shootStatus = 0;
		}
		
	}
	else if(!moving and shootStatus == 0)thisEntity.SetSprite("entities/dudeWalker3.png");
	if(dir)thisEntity.SetFlipX(false);
	if(!dir)thisEntity.SetFlipX(true);
	if(jumping and shootStatus == 0)thisEntity.SetSprite("entities/dudeJump.png");
	
	SetCameraPos(thisEntity.GetPositionXY() - vector2(400,400));

	// if the returned value is null, it means thisEntity doesn't have a physics body
	if (controller is null){
		print("Stuff");
		return;
		}
	ETHEntityArray ladders;
	GetEntityArray("ladder.ent", ladders);
	ladder = false;
	for(int i = 0; i < ladders.Size(); i++){
		if(distance(ladders[i].GetPositionXY(),thisEntity.GetPositionXY()) < 90)ladder = true;
	}
	if(!ladder)controller.SetGravityScale(1.0f);
	// move the character to the right
	if(input.KeyDown(K_D) and moveRight){
		//controller.SetLinearVelocity(vector2(6.0f, 0.0f));
		thisEntity.AddToPositionX(6.0f);
		moving = true;
		dir = true;
	}
	if(input.KeyDown(K_A) and moveLeft){
		thisEntity.AddToPositionX(-6.0f);
		moving = true;
		dir = false;
		//print("things");
	}
	if(input.KeyDown(K_W) and ladder){
		if(ladder)controller.SetGravityScale(0.0f);
		thisEntity.AddToPositionY(-10.0f);
	}
	else if(input.GetKeyState(K_W) == KS_HIT and GetTime() - lastHit > 1000 and controller.GetLinearVelocity().y <= 0.0f and !ladder){
		lastHit = GetTime();
		controller.SetLinearVelocity(vector2(0.0f,-10.0f));
		jumping = true;
		//print("things");
	}
	if(input.GetKeyState(K_SPACE) == KS_HIT){
		shootStatus = 1;
		if(dir){
		int id = AddEntity("bullet.ent", thisEntity.GetPosition() + vector3(2.0f,0.0f,0.0f));
		SeekEntity(id).SetInt("time",GetTime());
		SeekEntity(id).SetString("dir","right");
		}
		if(!dir){
		int id = AddEntity("bullet.ent", thisEntity.GetPosition() + vector3(-10.0f,0.0f,0.0f));
		SeekEntity(id).SetInt("time",GetTime());
		SeekEntity(id).SetString("dir","left");
		}
	}
	if(input.KeyDown(K_Q)){
		HideT();
	}
	if(input.KeyDown(K_E)){
		UnhideT();
	}
}

void ETHBeginContactCallback_char(ETHEntity@ thisEntity,ETHEntity@ other,vector2 contactPointA,vector2 contactPointB,vector2 contactNormal){
	if ((other.GetEntityName() == "wall.ent" or other.GetEntityName() == "movingPlat.ent" or other.GetEntityName() == "box.ent") and other.GetPositionY() > thisEntity.GetPositionY()){
		// a 'bullet.ent' hit the TNT barrel, that must result in an explosion
		jumping = false;
	}
	ETHInput@ input = GetInputHandle();
	if(other.GetEntityName() == "phaseWall.ent" and input.KeyDown(K_D)){
			ETHPhysicsController@ controller = other.GetPhysicsController();
			controller.SetDensity(0.0f);
		}
}


void ETHBeginContactCallback_enemy(ETHEntity@ thisEntity,ETHEntity@ other,vector2 contactPointA,vector2 contactPointB,vector2 contactNormal){
	if (other.GetEntityName() == "bullet.ent")
	{
		// a 'bullet.ent' hit the TNT barrel, that must result in an explosion
		thisEntity.SetString("status","dead");
	}
}

void ETHBeginContactCallback_bullet(ETHEntity@ thisEntity,ETHEntity@ other,vector2 contactPointA,vector2 contactPointB,vector2 contactNormal){
	if (other.GetEntityName() == "wall.ent" or other.GetEntityName() == "enemy.ent")
	{
		// a 'bullet.ent' hit the TNT barrel, that must result in an explosion
		thisEntity.SetString("status","dead");
	}
}

void ETHCallback_bullet(ETHEntity@ thisEntity){
	ETHPhysicsController@ controller = thisEntity.GetPhysicsController();
	if(thisEntity.GetString("dir") == "right")controller.SetLinearVelocity(vector2(50.0f,0.0f));
	if(thisEntity.GetString("dir") == "left")controller.SetLinearVelocity(vector2(-50.0f,0.0f));
	if(GetTime() - thisEntity.GetInt("time") > 1000) DeleteEntity(thisEntity);
	if(thisEntity.GetString("status") == "dead")DeleteEntity(thisEntity);
}

void ETHCallback_movingPlat(ETHEntity@ thisEntity){
	if(thisEntity.GetString("dir") == "right"){
		thisEntity.AddToPositionX(1.0f);
		if(thisEntity.GetPositionX() >= thisEntity.GetFloat("rightBound"))thisEntity.SetString("dir","left");
		}
	if(thisEntity.GetString("dir") == "left"){
		thisEntity.AddToPositionX(-1.0f);
		if(thisEntity.GetPositionX() <= thisEntity.GetFloat("leftBound"))thisEntity.SetString("dir","right");
		}
	if(thisEntity.GetString("dir") == "down"){
		thisEntity.AddToPositionY(1.0f);
		if(thisEntity.GetPositionY() >= thisEntity.GetFloat("rightBound"))thisEntity.SetString("dir","up");
		}
	if(thisEntity.GetString("dir") == "up"){
		thisEntity.AddToPositionY(-1.0f);
		if(thisEntity.GetPositionY() <= thisEntity.GetFloat("leftBound"))thisEntity.SetString("dir","down");
		}
}



void ETHBeginContactCallback_spikes(ETHEntity@ thisEntity,ETHEntity@ other,vector2 contactPointA,vector2 contactPointB,vector2 contactNormal){
	if (other.GetEntityName() == "char.ent")
	{
		// a 'bullet.ent' hit the TNT barrel, that must result in an explosion
		dead = true;
	}
}