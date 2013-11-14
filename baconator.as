/*
	The Baconator
	Created and Developed by: Kevin John Hohl (S0187382)
	MMST12017 Interactive Animation for Games
	Copyright (c) 2011
*/

package  {
	import flash.display.MovieClip;
	import flash.events.*;
	import com.coreyoneil.collision.CollisionList;
	import flash.utils.Timer;
	import flash.text.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.net.SharedObject;
	
	public class baconator extends MovieClip {
				
		//GAME CONSTANTS
		private var CHICKEN_KILL_POINTS = 100;
		private var SNAKE_TOUCH_DEDUCTION = 100;
		private var GAME_WIN_SCORE = 1000000000; //nobody wins
		private var MAX_GAME_SPEED = 35;
		private var MAX_SCORE_SIZE = 50;
		private var gravity:Number = 0.98;
		private var maxGravity:Number = 8;
		private var maxLift:Number = 6;
			
		//Game Variables
		private var gameSpeed:Number;
		private var whenToSpeedUp:Number = 0;
		private var enemyChicken:Chicken = new Chicken();
		private var enemySnake:Snake = new Snake();
		private var enemyCow:Cow = new Cow();
		private var playerPig:Pig;
		private var gamePlaying:Boolean;
		private var baconShare:SharedObject = SharedObject.getLocal('baconshare53846');
		
		//score variables
		private var score:Number;
		private var scoreTextField:TextField = new TextField();
		private var font1 = new scoreFont();
		private var myFormat:TextFormat = new TextFormat();
		
		//background images
		private var scroll1:scrollBG = new scrollBG();
		private var scroll2:scrollBG = new scrollBG(); //need 2 instances, one scrolls after the other one
		
		//music
		private var backgroundMusic:Sound = new Sound();
		private var backgroundMusic_Channel:SoundChannel = new SoundChannel();
		
		//sound effects
		private var pigdashMusic:Sound = new Sound();
		private var pigdashMusic_Channel:SoundChannel = new SoundChannel();
		
		private var cowGrowl:Sound = new Sound();
		private var cowGrowl_Channel:SoundChannel = new SoundChannel();
		
		private var chickenDie:Sound = new Sound();
		private var chickenDie_Channel:SoundChannel = new SoundChannel();
		
		private var snakeHiss:Sound = new Sound();
		private var snakeHiss_Channel:SoundChannel = new SoundChannel();
		
		private var pigSqueal:Sound = new Sound();
		private var pigSqueal_Channel:SoundChannel = new SoundChannel();
		
		
		public function baconator() {
			// constructor code
			
			//initialize the music and soundeffects
			initializeMusic();
			
		}
		
		function initializeGame():void {
			
			initializeElements();
			
			//create the enemies!
			createCow();
			createChicken();
			createSnake();
			
			//set gameplaying to true and initialize variables
			gamePlaying = true;
			gameSpeed = 10;
			score = 0;
			
			//start the music!
			backgroundMusic_Channel = backgroundMusic.play(80000,999);
			myFormat.color = 0xFFCC00;   
			myFormat.size = 15;
			myFormat.align = TextFormatAlign.CENTER;
			myFormat.font = font1.fontName;
			scoreTextField.defaultTextFormat = myFormat; 
			scoreTextField.autoSize = TextFieldAutoSize.CENTER;  
			scoreTextField.width = 50;
			scoreTextField.height = 20;
			scoreTextField.x = 400;
			scoreTextField.y = 10;
			scoreTextField.selectable = false;  
			addChild(scoreTextField)
			
			stage.focus=stage;// needed because stage loses focus and keyboardevents didnt work until i clicked within the stage
		}
		
		function initializeElements():void {
			
			//background
			scroll1.x = 0;
			scroll2.x = scroll1.width;				
			addChild(scroll1); 
			addChild(scroll2);
			
			//create flying pig
			playerPig = new Pig();
			
			//initialize chicken invulnerability state
			var isInvo:Boolean = false;
			var canBeInvo:Boolean = true;
			var invoPig:InvulnerablePig = new InvulnerablePig();
			
			//initialize collision lists
			var chickenCollisionList:CollisionList = new CollisionList(playerPig);
			var cowCollisionList:CollisionList = new CollisionList(playerPig);			
			var snakeCollisionList:CollisionList = new CollisionList(playerPig);
			var cowChickenCollisionList:CollisionList = new CollisionList(enemyChicken);			
			var snakeChickenCollisionList:CollisionList = new CollisionList(enemyChicken);
			snakeChickenCollisionList.addItem(enemySnake);
			cowChickenCollisionList.addItem(enemyCow);
			snakeCollisionList.addItem(enemySnake);
			cowCollisionList.addItem(enemyCow);
			chickenCollisionList.addItem(enemyChicken);
			
			//initialize pig movement variables
			var moveUp:Boolean = false;
			var spacebarPressed:Boolean = false;
			var pigDown:Number = 0;

			//resize pig because I drew it too small
			playerPig.scaleX=1.15;
			playerPig.scaleY=1.15;
			invoPig.scaleX=1.15;
			invoPig.scaleY=1.15;
						
			//position pig
			playerPig.y = 100;
			playerPig.x = 125;			
			addChild(playerPig);
			
			//event listeners
			stage.addEventListener(MouseEvent.MOUSE_UP, reportKeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, reportKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, reportUpArrowUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, reportUpArrowDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, reportSpace);
			stage.addEventListener(Event.ENTER_FRAME, EnterFrame);			
			
			
			// Keyboard functions
			function reportKeyUp(e:MouseEvent):void {
				moveUp = false;
			}
			function reportKeyDown(e:MouseEvent):void {
				moveUp = true;
			}
			function reportUpArrowUp(event:KeyboardEvent):void {
				if (event.keyCode == 38) { //38 = up arrow key
					moveUp = false;
				}
			}
			function reportUpArrowDown(event:KeyboardEvent):void {
				if (event.keyCode == 38) { //38 = up arrow key
					moveUp = true;
				}
			}
			
			function reportSpace(e:KeyboardEvent):void {
				
				if (e.keyCode == 32) {					
				
					//invulnerability timers
					var invoTimer:Timer = new Timer(650,1); // .65 seconds
					var disableInvoTimer:Timer = new Timer(700,1); // .7 seconds
					
					invoTimer.addEventListener(TimerEvent.TIMER, invoMode);
					disableInvoTimer.addEventListener(TimerEvent.TIMER, disableInvo);
					
					//check if pig can become invulnerable (invo)
					if (canBeInvo == true) {
						isInvo = true;
						invoTimer.start();					
						addChild(invoPig);
						pigdashMusic_Channel = pigdashMusic.play();
						canBeInvo = false;;
						gameSpeed += 10;
					}				
									
					function invoMode():void {
						if (isInvo == true) {
							removeChild(invoPig);
						}
						if (gamePlaying) {
							gameSpeed -= 10;
						}
						disableInvoTimer.start();
						invoTimer.removeEventListener(TimerEvent.TIMER, invoMode);
						isInvo = false;
					}
					function disableInvo():void {
						
						canBeInvo = true;
						//pigdashMusic_Channel.stop();
						disableInvoTimer.removeEventListener(TimerEvent.TIMER, disableInvo);
					}
				}
			}
			
			//Enter Frame Function (this happens over and over repeatedly)
			function EnterFrame(event:Event):void {
				
				//for scrolling background
				scroll1.x -= gameSpeed;  
				scroll2.x -= gameSpeed;  
			
				if(scroll1.x < -scroll1.width){
					scroll1.x = scroll2.x + scroll2.width;
				}
				if(scroll2.x < -scroll2.width){
					scroll2.x = scroll1.x + scroll1.width;
				}
				
				//reposition invopig to follow pig
				invoPig.x = playerPig.x;
				invoPig.y = playerPig.y;
				
				
				//incrementing score and speeding up game
				if (gamePlaying) {
					score+= Math.floor(Math.random()*(3))+1;
					whenToSpeedUp++
					
					if (whenToSpeedUp >= 100) {
						
						if (myFormat.size < MAX_SCORE_SIZE) {
							myFormat.size += 1;
							scoreTextField.defaultTextFormat = myFormat;
						}
						
						if (gameSpeed < MAX_GAME_SPEED) {
							gameSpeed += 0.75;
							whenToSpeedUp = 0;
						}
					}
					
					if (score >= GAME_WIN_SCORE) {
						wonGame();
					}
				}
				scoreTextField.text = String(score).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,");
				
				//pig movement code
				pigDown += gravity;
				
				if (playerPig.y <= 570) {
					playerPig.y += pigDown;
				} 
				else
				{
					pigSqueal_Channel = pigSqueal.play(500,1);
					lostGame();
				}
				if (pigDown > maxGravity) {
					pigDown = maxGravity;
				}
				else if (pigDown < -maxLift){
					pigDown = -maxLift;
				}
					
				if (moveUp) {
					if (playerPig.y >= 50) {
						pigDown -= 2;
					}
					else 
					{
						pigSqueal_Channel = pigSqueal.play(500,1);
						lostGame();
					}
				}
				
				//cow movement code
				enemyCow.x -= gameSpeed+(gameSpeed/3);
				
				if (enemyCow.x < -200) {
					enemyCow.x = ( Math.random()*1000 )+1000;
				}
				
				//chicken movement code
				enemyChicken.x -= gameSpeed+(gameSpeed/8);
				
				if (enemyChicken.x < -200) {
					enemyChicken.x = ( Math.random()*1500 )+1000;
					enemyChicken.y = ( Math.random()*325 ) + 75;
				}
				
				//snake movement code
				enemySnake.x -= gameSpeed;
				
				if (enemySnake.x < -200) {
					enemySnake.x = ( Math.random()*2000 )+800;
				}
				
			//Collision testing
				
				//Chicken collission with cow and snake
				var cowChickenCollisionArray:Array = cowChickenCollisionList.checkCollisions();
				var snakeChickenCollisionArray:Array = snakeChickenCollisionList.checkCollisions();
				
				if(cowChickenCollisionArray.length > 0 ) {
					enemyChicken.y -= 10; //incase chicken and cow/snake spawn in the same place
				}else if ( snakeChickenCollisionArray.length > 0) {
					enemyChicken.y += 10;
				}
				
				//Cow Collision
				var cowCollisionArray:Array = cowCollisionList.checkCollisions();
				if(cowCollisionArray.length > 0)  {
					cowGrowl_Channel = cowGrowl.play()
					lostGame();
				}
				
				//Snake Collision
				var snakeCollisionArray:Array = snakeCollisionList.checkCollisions();
				var pointsMinus:minus100 = new minus100();
				
				if(snakeCollisionArray.length > 0)  {
					
					snakeHiss_Channel = snakeHiss.play(500,1);
					
					pointsMinus.x = enemySnake.x;
					pointsMinus.y = enemySnake.y;						
					addChild(pointsMinus);
					pigDown += (Math.random()*90) + 30; //snake pushes pig 30-120 pixels down if touched 
					score -= SNAKE_TOUCH_DEDUCTION; //deduct 100 points from score if snake is hit
					
					var minusPointsTimer:Timer = new Timer(500,1); //
					minusPointsTimer.addEventListener(TimerEvent.TIMER, minusPointsFunction);
					minusPointsTimer.start();
					
					function minusPointsFunction():void {
						removeChild(pointsMinus);
						minusPointsTimer.removeEventListener(TimerEvent.TIMER, minusPointsFunction);
					}
				}
				
				//Chicken Collision
				var chickenCollisionArray:Array = chickenCollisionList.checkCollisions();
				var explosion:explode = new explode();
				var pointsPlus:plus100 = new plus100();
				
				if(chickenCollisionArray.length > 0)  {
					if (isInvo == true) {						
					
						chickenDie_Channel = chickenDie.play(200,1);
						
						pointsPlus.x = enemyChicken.x;
						pointsPlus.y = enemyChicken.y;						
						addChild(pointsPlus);
						explosion.x = enemyChicken.x;
						explosion.y = enemyChicken.y;						
						addChild(explosion);
						enemyChicken.x += (Math.random()*1500) + 1200;
						enemyChicken.y = (Math.random()*325) + 75;
						score+= CHICKEN_KILL_POINTS; //add 100 points to score if snake is hit
						
						var explodeTimer:Timer = new Timer(75,1); 
						explodeTimer.addEventListener(TimerEvent.TIMER, explodeFunction);
						explodeTimer.start();
						
						function explodeFunction():void {
							removeChild(explosion);
							explodeTimer.removeEventListener(TimerEvent.TIMER, explodeFunction);
						}
						var pointsTimer:Timer = new Timer(500,1); //
						pointsTimer.addEventListener(TimerEvent.TIMER, pointsFunction);
						pointsTimer.start();
						
						function pointsFunction():void {
							removeChild(pointsPlus);
							pointsTimer.removeEventListener(TimerEvent.TIMER, pointsFunction);
						}
					} else {
						pigSqueal_Channel = pigSqueal.play(500,1);
						lostGame();
					}
				}
								
			}
			
			//lose game function
			function lostGame() {
							
				stage.removeEventListener(Event.ENTER_FRAME, EnterFrame);
				stage.removeEventListener(MouseEvent.MOUSE_UP, reportKeyUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, reportKeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, reportSpace);
				gamePlaying = false;
				gameSpeed = 0;
				backgroundMusic_Channel.stop();
				
				var waitTimer:Timer = new Timer(2000,1); //
				waitTimer.addEventListener(TimerEvent.TIMER, waitFunction);
				waitTimer.start();
				
				function waitFunction():void {
					removeChild(enemyCow);
					removeChild(enemyChicken);
					removeChild(enemySnake);
					removeChild(playerPig);
					removeChild(scroll1);
					removeChild(scroll2);
					//removeChild(scoreTextField);
					scoreTextField.y = 300;
					waitTimer.removeEventListener(TimerEvent.TIMER, waitFunction);
					pigSqueal_Channel = pigSqueal.play(500,1);
					gotoAndStop("Lose");
					sethighscore();
					
				}
				
			}
			
			//Win game function
			function wonGame() {
				
				stage.removeEventListener(Event.ENTER_FRAME, EnterFrame);
				stage.removeEventListener(MouseEvent.MOUSE_UP, reportKeyUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, reportKeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, reportSpace);
				gamePlaying = false;
				gameSpeed = 0;
				backgroundMusic_Channel.stop();			
				removeChild(enemyCow);
				removeChild(enemyChicken);
				removeChild(enemySnake);
				removeChild(playerPig);
				removeChild(scroll1);
				removeChild(scroll2);
				removeChild(scoreTextField);
				gotoAndStop("Win");
				sethighscore();								
			}
			
						
		}
		
		private function sethighscore():void {
			
			try 
			{
				if ( baconShare.data.highScore == null )
				{
					baconShare.data.highScore = score;
					//trace("new score made: " + baconShare.data.highScore);
				}
				else if ( score > baconShare.data.highScore )
				{
					baconShare.data.highScore = score;
					//trace("score updated: " + baconShare.data.highScore);
				}
				baconShare.flush();
				highscoretxt.text = baconShare.data.highScore.toString().replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,");				
				baconShare.close();
			}
			catch ( err:Error )
			{
				trace( "Error Caught:", err.name, err.message );
			}
		}
		
		
		//function used to create a cow
		function createCow():void {
				
			enemyCow.scaleX = 0.85;
			enemyCow.scaleY = 0.85;
			enemyCow.y = 480;
			enemyCow.x = ( Math.random()*1000 )+1000;
			
			addChild(enemyCow);
				
		}
		
		//function used to create a snake
		function createSnake():void {
				
			enemySnake.scaleX = 0.65;
			enemySnake.scaleY = 0.65;
			enemySnake.y = 150;
			enemySnake.x = ( Math.random()*1500 )+1200;
			
			addChild(enemySnake);
				
		}
		
		//function used to create a chicken
		function createChicken():void {
			
			enemyChicken.scaleX = 0.15;
			enemyChicken.scaleY = 0.15;
			enemyChicken.y = (Math.random()*325) + 75;
			enemyChicken.x = ( Math.random()*1500 )+900;
			
			addChild(enemyChicken);
		}
		
		//function to restart the game 
		function restartGame():void {
			initializeGame();
		}
		
		//MUSIC & SOUND//
		function initializeMusic() {
		
			backgroundMusic.load(new URLRequest("Sounds/BeautifulLies.mp3"));
			pigdashMusic.load(new URLRequest("Sounds/boom.mp3"));
			cowGrowl.load(new URLRequest("Sounds/growl1.mp3"));
			chickenDie.load(new URLRequest("Sounds/chicken.mp3"));
			snakeHiss.load(new URLRequest("Sounds/snakehiss.mp3"));
			pigSqueal.load(new URLRequest("Sounds/pigsqueal.mp3"));
					
		}
	
	
	}
	
}


