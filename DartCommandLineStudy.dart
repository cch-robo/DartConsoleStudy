#import('dart:io');

/**
 * dart サーバ再度処理実装の練習プログラム
 */
void main() {
  print('input command, if . only line is command end.');
  readConsoleLine();
}
bool IS_DEBUG = false;

/**
 * コンソールからの入力を取得する。
 * '.' のみの入力で処理を終了します。
 * 現在 2012/05/18 デバッグ途中のためバグがあります。
 * 非同期処理の対応未完成のためか、
 * '.' のみの入力でも処理が終了しないなど。
 */
void readConsoleLine(){
  String       command;
  List<String> arguments = new List<String>();
  
  var stream = new StringInputStream(stdin); 
  stream.onLine = () { 
    String line = stream.readLine();
    if (line != null) {
      if(line == "."){
        print("command line end.");
        return;
      }

      //コンソール入力をコマンドラインと仮定して、
      //引数区切り' 'スペースによる
      //コマンドと引数の分割を行います。
      List<String> options = line.split(" ");
      for(int index = 0; index < options.length; index++){
        if(index == 0){
          command = options[index];
        }else{
          arguments.add(options[index]);
        }
      }
      
      //動作確認デバッグ出力
      if(IS_DEBUG){
        String temp = "command = ".concat(command);
        for(String arg in arguments){
          temp = temp.concat(", ").concat(arg);
        }
        print("imput is " + temp + " (args = ${arguments.length})");
      }
    }
    
    //入力をコマンド入力として実行させます。
    if(line != ""){
      execProcess(command, arguments);
    }
  }; 
}

/**
 * 引数のコマンドを実行します。
 */
bool execProcess(String command, List<String> arguments) {
  //参考元： dart artuiles
  //　　　　 Interacting with processes
  //var p = Process.start('ls', ['-l']);
  //var stdoutStream = new StringInputStream(p.stdout);
  //p.onExit = (exitCode) {
  //  print('exit code: $exitCode');
  //  p.close();
  //};
  
  bool         isSuccess = false;
  List<String> results = new List<String>();
  int          exit_code;
  var process = Process.start(command, arguments);
  
  var stdoutStream = new StringInputStream(process.stdout);
  stdoutStream.onLine = (){
    String line = stdoutStream.readLine();
    results.add(line);
    
    //2012/05/18 現時点のデバッグ用
    print('${results.length}:${line}');
  };
  
  //2012/05/18 現時点では、
  //stdoutstream.onLine() の全実行が終了する前に、
  //process.onEit() が実行されてしまっている。
  process.onExit = (exitCode) {
    exit_code = exitCode;
    
    if(exitCode == 0){
      isSuccess = true;
    }else{
      isSuccess = false;
    }
    process.close();
    
    //デバッグ出力
    if(IS_DEBUG){
      String result = "";
      for(String line in results){
        result = result.concat(line).concat('\n');
      }
      print('results is ${results.length}');
      print('result is ${result}, exit code is ${exit_code} : ${isSuccess}');
    }
  };
  
  return isSuccess;
}
