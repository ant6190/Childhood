/*
 Hello world!
*/

#include "eth_util.angelscript"

int lastHit = 0;
bool dir = false;

void main()
{
	LoadScene("scenes/test.esc", "", "");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void ETHCallback_char(ETHEntity@ thisEntity)
{
	ETHPhysicsController@ controller = thisEntity.GetPhysicsController();
	ETHInput@ input = GetInputHandle();
	
	SetCameraPos(thisEntity.GetPositionXY() - vector2(400,400));

	// if the returned value is null, it means thisEntity doesn't have a physics body
	if (controller is null){
		print("Stuff");
		return;
		}

	// move the character to the right
	if(input.KeyDown(K_D)){
		//controller.SetLinearVelocity(vector2(6.0f, 0.0f));
		thisEntity.AddToPositionX(6.0f);
		dir = true;
	}
	if(input.KeyDown(K_A)){
		thisEntity.AddToPositionX(-6.0f);
		dir = false;
		//print("things");
	}
	if(input.GetKeyState(K_W) == KS_HIT and GetTime() - lastHit > 1000 and controller.GetLinearVelocity().y <= 0.0f){
		lastHit = GetTime();
		controller.SetLinearVelocity(vector2(0.0f,-12.0f));
		//print("things");
	}
	if(input.KeyDown(K_SPACE)){
		int id = AddEntity("bullet.ent", thisEntity.GetPosition());
		SeekEntity(id).SetInt("time",GetTime());
	}
}

void ETHCallback_bullet(ETHEntity@ thisEntity){
	ETHPhysicsController@ controller = thisEntity.GetPhysicsController();
	if(dir)controller.SetLinearVelocity(vector2(50.0f,0.0f));
	if(!dir)controller.SetLinearVelocity(vector2(-50.0f,0.0f));
	if(GetTime() - thisEntity.GetInt("time") > 1000) DeleteEntity(thisEntity);
}