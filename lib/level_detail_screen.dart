import 'dart:async';

import 'package:flutter/material.dart';

import 'level_quiz_screen.dart';

import 'theme_selection_screen.dart';

import 'widgets/think_cards.dart';


class LevelDetailScreen extends StatefulWidget {

  final int level;

  final String title;

  final String subtitle;

  final Color accentColor;

  final AppTheme theme;

  const LevelDetailScreen({

    super.key,

    required this.level,

    required this.title,

    required this.subtitle,

    required this.accentColor,

    required this.theme,

  });

  @override

  State<LevelDetailScreen> createState() => _LevelDetailScreenState();

}

class _LevelDetailScreenState extends State<LevelDetailScreen> {

  late final LevelContent content;

  final List<String?> _answers = [null, null, null, null];

  int _activeBlank = 0;

  bool _submitted = false;

  bool _showCodeOnMobile = false;

  int _flashCardIndex = 0;

  bool _flashCardRevealed = false;

  @override

  void initState() {

    super.initState();

    content = LevelContent.forLevel(widget.level);

  }

  @override

  Widget build(BuildContext context) {

    final isLevelOne = widget.level == 1;

    return Scaffold(

      backgroundColor: _backgroundColor,

      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0, title: Text('LEVEL ${widget.level}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2))),

      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18,8,18,30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        _buildHeader(), const SizedBox(height:14),

        if (isLevelOne) _buildLevelOneWorkspace() else ...[

          _buildProblem(), const SizedBox(height:14),
          if (widget.level == 2) ...[
            _buildVisualExplanation(),
            const SizedBox(height:14),
          ],
          _buildIntuition(), const SizedBox(height:14), _buildConcept(), const SizedBox(height:14), _buildHints(), const SizedBox(height:14), _buildComplexity(), const SizedBox(height:24), _buildAssessmentButton(),

        ],

      ]))),

    );

  }

  Color get _backgroundColor {

    switch (widget.theme) {

      case AppTheme.forest: return const Color(0xFF06130F);

      case AppTheme.cyberpunk: return const Color(0xFF09051A);

      case AppTheme.kingdom: return const Color(0xFF170D05);

    }

  }

  Widget _buildLevelOneWorkspace() {

    return LayoutBuilder(builder: (context,constraints) {

      final learn=Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_buildProblem(),const SizedBox(height:14),_buildIntuition(),const SizedBox(height:14),_buildConcept(),const SizedBox(height:14),_buildThinkCard(),const SizedBox(height:14),_buildComplexity()]);

      if(constraints.maxWidth>=850){return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:learn),const SizedBox(width:16),Expanded(child:_buildCodeEditor())]);}

      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_buildMobileModeSwitcher(),const SizedBox(height:14),_showCodeOnMobile?_buildCodeEditor():learn]);

    });

  }

  Widget _buildMobileModeSwitcher(){return Container(width:double.infinity,padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.35),borderRadius:BorderRadius.circular(16),border:Border.all(color:widget.accentColor.withValues(alpha:.25))),child:Row(children:[Expanded(child:_modeButton(Icons.menu_book_rounded,'LEARN',!_showCodeOnMobile,()=>setState(()=>_showCodeOnMobile=false))),const SizedBox(width:4),Expanded(child:_modeButton(Icons.code_rounded,'CODE',_showCodeOnMobile,()=>setState(()=>_showCodeOnMobile=true)))]));}

  Widget _modeButton(IconData icon,String label,bool selected,VoidCallback onTap){return InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),child:AnimatedContainer(duration:const Duration(milliseconds:180),padding:const EdgeInsets.symmetric(vertical:12),decoration:BoxDecoration(color:selected?widget.accentColor.withValues(alpha:.18):Colors.transparent,borderRadius:BorderRadius.circular(12),border:Border.all(color:selected?widget.accentColor.withValues(alpha:.55):Colors.transparent)),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:18,color:selected?widget.accentColor:Colors.white54),const SizedBox(width:7),Text(label,style:TextStyle(color:selected?widget.accentColor:Colors.white60,fontSize:12,fontWeight:FontWeight.w900,letterSpacing:.8))])));}

  List<Map<String,String>> get _levelOneFlashCards=>const[

    {'title':'SCORE CHECK','question':'What information is given?','body':'Three placement scores are given as input:\n\n70   65   60','answer':'70, 65 and 60'},

    {'title':'TOTAL SCORE','question':'What should you calculate first?','body':'Add all three placement scores together.','answer':'70 + 65 + 60 = 195'},

    {'title':'QUALIFICATION','question':'What value must the total reach?','body':'The student qualifies when the total score is 180 or more.','answer':'The cutoff is 180'},

    {'title':'CONDITION','question':'What condition should the code check?','body':'Compare the total score with the qualification threshold.','answer':'total >= 180'},

    {'title':'FINAL RESULT','question':'Does this student qualify?','body':'The calculated total is 195. Is 195 at least 180?','answer':'YES — QUALIFIED'},

  ];

  Widget _buildThinkCard(){final card=_levelOneFlashCards[_flashCardIndex];return _sectionCard(icon:Icons.style_rounded,title:'🧠 FLASH CARDS',child:Column(children:[GestureDetector(onTap:()=>setState(()=>_flashCardRevealed=!_flashCardRevealed),child:_flashCard(card)),const SizedBox(height:10),Row(children:[IconButton(onPressed:_flashCardIndex>0?_previousFlashCard:null,icon:const Icon(Icons.arrow_back_rounded),color:Colors.white),Expanded(child:_flashDots()),IconButton(onPressed:_flashCardIndex<_levelOneFlashCards.length-1?_nextFlashCard:null,icon:const Icon(Icons.arrow_forward_rounded),color:Colors.white)])]));}

  Widget _flashCard(Map<String,String> card){final answer=_flashCardRevealed;return AnimatedSwitcher(duration:const Duration(milliseconds:220),child:Container(key:ValueKey('$_flashCardIndex-$answer'),width:double.infinity,height:320,padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[widget.accentColor.withValues(alpha:.30),widget.accentColor.withValues(alpha:.10)]),borderRadius:BorderRadius.circular(18),border:Border.all(color:widget.accentColor.withValues(alpha:.42))),child:Column(children:[Text(answer?'ANSWER':card['title']!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:30),if(!answer)...[Text('Q: ${card['question']!}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w800,height:1.35)),const SizedBox(height:25),Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.16),borderRadius:BorderRadius.circular(8)),child:Text(card['body']!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14,fontWeight:FontWeight.w700,height:1.5))),const Spacer(),const Text('Tap to reveal',style:TextStyle(color:Colors.white70,fontSize:13,fontWeight:FontWeight.w700))]else...[const SizedBox(height:25),Container(padding:const EdgeInsets.symmetric(horizontal:22,vertical:16),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.72),borderRadius:BorderRadius.circular(4)),child:Text(card['answer']!,textAlign:TextAlign.center,style:TextStyle(color:widget.accentColor,fontSize:20,fontWeight:FontWeight.w900,fontFamily:'monospace'))),const Spacer(),const Text('Tap to hide',style:TextStyle(color:Colors.white60,fontSize:12))]])));}

  Widget _flashDots()=>Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(_levelOneFlashCards.length,(i)=>AnimatedContainer(duration:const Duration(milliseconds:180),margin:const EdgeInsets.symmetric(horizontal:3),width:i==_flashCardIndex?12:9,height:i==_flashCardIndex?12:9,decoration:BoxDecoration(color:i==_flashCardIndex?Colors.white:widget.accentColor.withValues(alpha:.55),shape:BoxShape.circle))));

  void _previousFlashCard(){setState(() { _flashCardIndex--; _flashCardRevealed = false; });}

  void _nextFlashCard(){setState(() { _flashCardIndex++; _flashCardRevealed = false; });}

  Widget _buildCodeEditor(){return _sectionCard(icon:Icons.code_rounded,title:'💻 FILL THE CODE',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Complete the missing values using the keywords below.',style:TextStyle(color:Colors.white70,fontSize:13)),const SizedBox(height:14),Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.45),borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_codeRow('int total = ',0,' + '),_codeRow('',1,' + '),_codeRow('',2,';'),const SizedBox(height:8),Row(children:[const Text('if (total >= ',style:TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14)),_blankBox(3),const Text(') {',style:TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14))]),const Padding(padding:EdgeInsets.only(left:20,top:5),child:Text('return "Qualified";',style:TextStyle(color:Colors.white70,fontFamily:'monospace',fontSize:14))),const Text('}',style:TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14))])),const SizedBox(height:14),Text('KEYWORDS',style:TextStyle(color:widget.accentColor,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:['70','65','60','180'].map((v)=>ActionChip(label:Text(v),onPressed:()=>_fillAnswer(v),backgroundColor:widget.accentColor.withValues(alpha:.14),side:BorderSide(color:widget.accentColor.withValues(alpha:.4)),labelStyle:TextStyle(color:widget.accentColor,fontWeight:FontWeight.w900))).toList()),const SizedBox(height:16),SizedBox(width:double.infinity,height:50,child:ElevatedButton.icon(onPressed:_submitted?null:_submitLevelOneCode,icon:Icon(_submitted?Icons.check_rounded:Icons.play_arrow_rounded),label:Text(_submitted?'COMPLETED':'SUBMIT CODE',style:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:.8)),style:ElevatedButton.styleFrom(backgroundColor:widget.accentColor,foregroundColor:Colors.black))) ]));}

  Widget _codeRow(String prefix,int index,String suffix)=>Row(children:[Flexible(child:Text(prefix,style:const TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14))),_blankBox(index),Flexible(child:Text(suffix,style:const TextStyle(color:Colors.white,fontFamily:'monospace',fontSize:14)))]);

  Widget _blankBox(int index){final value=_answers[index];return GestureDetector(onTap:()=>setState(()=>_activeBlank=index),child:Container(margin:const EdgeInsets.symmetric(horizontal:3,vertical:3),padding:const EdgeInsets.symmetric(horizontal:8,vertical:6),decoration:BoxDecoration(color:value==null?widget.accentColor.withValues(alpha:.12):widget.accentColor.withValues(alpha:.28),borderRadius:BorderRadius.circular(6),border:Border.all(color:widget.accentColor.withValues(alpha:.55))),child:Text(value??'?',style:TextStyle(color:value==null?widget.accentColor:Colors.white,fontFamily:'monospace',fontWeight:FontWeight.w900))));}

  void _fillAnswer(String value){setState((){_answers[_activeBlank]=value;if(_activeBlank<3)_activeBlank++;});}

  void _submitLevelOneCode(){final correct=_answers[0]=='70'&&_answers[1]=='65'&&_answers[2]=='60'&&_answers[3]=='180';if(!correct){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Not quite. Fill the values in the correct order.')));return;}setState(()=>_submitted=true);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('🎉 Level 1 completed! Great work.')));}

  Widget _buildHeader() {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(22),

        gradient: LinearGradient(

          colors: [

            widget.accentColor.withValues(alpha: 0.25),

            Colors.black.withValues(alpha: 0.35),

          ],

        ),

        border: Border.all(color: widget.accentColor.withValues(alpha: 0.5)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'LEVEL ${widget.level}',

            style: TextStyle(

              color: widget.accentColor,

              fontSize: 12,

              fontWeight: FontWeight.bold,

              letterSpacing: 2,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            content.title,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 25,

              fontWeight: FontWeight.w900,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            content.subtitle,

            style: const TextStyle(color: Colors.white60, fontSize: 13),

          ),

        ],

      ),

    );

  }

  Widget _buildProblem() {

    return _sectionCard(

      icon: Icons.flag_rounded,

      title: '🎯 THE CHALLENGE',

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            content.problem,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 14,

              height: 1.6,

              fontWeight: FontWeight.w600,

            ),

          ),

          const SizedBox(height: 16),

          _exampleBox(),

        ],

      ),

    );

  }

  Widget _exampleBox() {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: Colors.black.withValues(alpha: 0.30),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            'EXAMPLE',

            style: TextStyle(

              color: Colors.white54,

              fontSize: 10,

              fontWeight: FontWeight.bold,

              letterSpacing: 1.2,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            'Input: ${content.exampleInput}',

            style: const TextStyle(

              color: Colors.white,

              fontFamily: 'monospace',

              fontSize: 13,

            ),

          ),

          const SizedBox(height: 5),

          Text(

            'Output: ${content.exampleOutput}',

            style: const TextStyle(

              color: Colors.white,

              fontFamily: 'monospace',

              fontSize: 13,

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildIntuition() {

    return _sectionCard(

      icon: Icons.lightbulb_rounded,

      title: '💡 INTUITION',

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          for (int i = 0; i < content.intuition.length; i++) ...[

            _StepText(number: '${i + 1}', text: content.intuition[i]),

            if (i != content.intuition.length - 1) const SizedBox(height: 9),

          ],

        ],

      ),

    );

  }

  Widget _buildConcept() {

    return _sectionCard(

      icon: Icons.psychology_rounded,

      title: '🧠 WHAT SHOULD I USE?',

      child: Wrap(

        spacing: 8,

        runSpacing: 8,

        children: [

          for (final concept in content.concepts) _conceptChip(concept),

        ],

      ),

    );

  }

  Widget _conceptChip(String text) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(

        color: widget.accentColor.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),

      ),

      child: Text(

        text,

        style: TextStyle(

          color: widget.accentColor,

          fontSize: 12,

          fontWeight: FontWeight.bold,

        ),

      ),

    );

  }

  Widget _buildHints() {

    return _sectionCard(

      icon: Icons.auto_awesome_rounded,

      title: '🧠 THINK CARDS',

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            'Get progressive clues without revealing the solution immediately.',

            style: TextStyle(

              color: Colors.white70,

              fontSize: 13,

              height: 1.5,

            ),

          ),

          const SizedBox(height: 14),

          SizedBox(

            width: double.infinity,

            child: OutlinedButton.icon(

              onPressed: _openThinkCards,

              icon: const Icon(Icons.style_rounded),

              label: const Text(

                'OPEN THINK CARDS',

                style: TextStyle(

                  fontWeight: FontWeight.w900,

                  letterSpacing: 0.6,

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

  void _openThinkCards() {

    final cards = <ThinkCard>[];

    for (int i = 0; i < content.hints.length; i++) {

      final type = switch (i) {

        0 => 'CONCEPT',

        1 => 'APPROACH',

        2 => 'DIRECTION',

        _ => 'FINAL HINT',

      };

      final title = switch (i) {

        0 => 'Start with the idea',

        1 => 'Think about the approach',

        2 => 'Narrow it down',

        _ => 'You are almost there',

      };

      cards.add(

        ThinkCard(

          type: type,

          title: title,

          content: content.hints[i],

        ),

      );

    }

    showDialog(

      context: context,

      builder: (_) => ThinkCards(

        cards: cards,

        theme: widget.theme,

      ),

    );

  }

  Widget _buildVisualExplanation() {
    return _sectionCard(
      icon: Icons.play_circle_fill_rounded,
      title: '🎬 VISUAL EXPLANATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Watch how the Two Sum algorithm finds the pair step by step.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          const _TwoSumAnimation(),
        ],
      ),
    );
  }

  Widget _buildComplexity() {

    return _sectionCard(

      icon: Icons.speed_rounded,

      title: '⚡ COMPLEXITY',

      child: Row(

        children: [

          Expanded(

            child: Text(

              'Time: ${content.timeComplexity}',

              style: const TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

          Expanded(

            child: Text(

              'Space: ${content.spaceComplexity}',

              textAlign: TextAlign.right,

              style: const TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildAssessmentButton() {

    return SizedBox(

      width: double.infinity,

      height: 56,

      child: ElevatedButton.icon(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) => LevelQuizScreen(

                level: widget.level,

                accentColor: widget.accentColor,

                theme: widget.theme,

              ),

            ),

          );

        },

        icon: const Icon(Icons.quiz_rounded),

        label: const Text(

          'START 5 QUESTION ASSESSMENT',

          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),

        ),

      ),

    );

  }

  Widget _sectionCard({

    required IconData icon,

    required String title,

    required Widget child,

  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.black.withValues(alpha: 0.35),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Icon(icon, color: widget.accentColor, size: 20),

              const SizedBox(width: 8),

              Expanded(

                child: Text(

                  title,

                  style: TextStyle(

                    color: widget.accentColor,

                    fontSize: 12,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 1.2,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 14),

          child,

        ],

      ),

    );

  }

}

class _StepText extends StatelessWidget {

  final String number;

  final String text;

  const _StepText({required this.number, required this.text});

  @override

  Widget build(BuildContext context) {

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Container(

          width: 24,

          height: 24,

          alignment: Alignment.center,

          decoration: const BoxDecoration(

            color: Color(0x3322D3EE),

            shape: BoxShape.circle,

          ),

          child: Text(

            number,

            style: const TextStyle(

              color: Color(0xFF22D3EE),

              fontSize: 11,

              fontWeight: FontWeight.w900,

            ),

          ),

        ),

        const SizedBox(width: 10),

        Expanded(

          child: Text(

            text,

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 13,

              height: 1.5,

            ),

          ),

        ),

      ],

    );

  }

}

class LevelContent {

  final String title;

  final String subtitle;

  final String problem;

  final String exampleInput;

  final String exampleOutput;

  final List<String> intuition;

  final List<String> concepts;

  final List<String> hints;

  final String timeComplexity;

  final String spaceComplexity;

  const LevelContent({

    required this.title,

    required this.subtitle,

    required this.problem,

    required this.exampleInput,

    required this.exampleOutput,

    required this.intuition,

    required this.concepts,

    required this.hints,

    required this.timeComplexity,

    required this.spaceComplexity,

  });

  factory LevelContent.forLevel(int level) {

    switch (level) {

      case 1:

        return const LevelContent(

          title: 'CODE AWAKENING',

          subtitle: 'Pass the Placement Gate',

          problem:

              'A student has scores in three placement rounds. '

              'Calculate the total score. The student qualifies '

              'for the next round if the total score is 180 or more.',

          exampleInput: '70 65 60',

          exampleOutput: 'Qualified',

          intuition: [

            'Identify the three scores given as input.',

            'Calculate their total.',

            'Compare the total with the qualification threshold.',

            'Decide whether the student qualifies.',

          ],

          concepts: ['Variables', 'Arithmetic', 'if / else'],

          hints: [

            'What information is given, and what final value do you need to calculate?',

            'First calculate the sum of the three scores, then compare that sum with the cutoff.',

            'Your condition needs to check whether total >= 180.',

          ],

          timeComplexity: 'O(1)',

          spaceComplexity: 'O(1)',

        );

      case 2:

        return const LevelContent(

          title: 'ARRAY VAULT',

          subtitle: 'Find the pair that unlocks the vault',

          problem:

              'You are given an array of candidate scores and a target score. '

              'Find whether two different scores can combine to reach the target.',

          exampleInput: '[2, 7, 11, 15], target = 9',

          exampleOutput: '[2, 7]',

          intuition: [

            'For every number, think about what other number is needed to reach the target.',

            'Avoid checking every possible pair if you can remember values you have already seen.',

            'Use that stored information to quickly determine whether the required partner exists.',

          ],

          concepts: ['Arrays', 'Hashing', 'Complement'],

          hints: [

            'For a current value x, what value would complete the target?',

            'Think about storing values that you have already visited.',

            'A hash-based lookup can help you find the required complement quickly.',

          ],

          timeComplexity: 'O(n)',

          spaceComplexity: 'O(n)',

        );

      case 3:

        return const LevelContent(

          title: 'STRING CIPHER',

          subtitle: 'Decode the candidate identifier',

          problem:

              'A company receives two strings representing candidate IDs. '

              'Determine whether the second string can be formed by rearranging '

              'the characters of the first.',

          exampleInput: 'listen, silent',

          exampleOutput: 'True',

          intuition: [

            'The order of characters does not matter.',

            'What matters is how many times each character occurs.',

            'Compare the character frequencies in both strings.',

          ],

          concepts: ['Strings', 'Frequency Counting', 'Hash Map'],

          hints: [

            'If order does not matter, what information about each character matters?',

            'Count how often every character appears.',

            'Both strings must have identical character frequencies.',

          ],

          timeComplexity: 'O(n)',

          spaceComplexity: 'O(k)',

        );

      case 4:

        return const LevelContent(

          title: 'SEARCH PROTOCOL',

          subtitle: 'Locate the correct position',

          problem:

              'You are given a sorted list of placement scores. Find the position '

              'of a target score efficiently.',

          exampleInput: '[10, 20, 30, 40, 50], target = 40',

          exampleOutput: 'Index 3',

          intuition: [

            'The array is already sorted, so use that information.',

            'Instead of checking every element, inspect the middle.',

            'Use the comparison to eliminate half of the remaining search space.',

          ],

          concepts: ['Binary Search', 'Sorted Array', 'Divide and Conquer'],

          hints: [

            'What advantage does a sorted array give you?',

            'Look at the middle element first.',

            'Each comparison should allow you to discard roughly half the search space.',

          ],

          timeComplexity: 'O(log n)',

          spaceComplexity: 'O(1)',

        );

      case 5:

        return const LevelContent(

          title: 'SORTING ARENA',

          subtitle: 'Arrange the candidates',

          problem:

              'Given a collection of candidate scores, arrange them from the '

              'lowest score to the highest score before ranking the candidates.',

          exampleInput: '[40, 10, 30, 20]',

          exampleOutput: '[10, 20, 30, 40]',

          intuition: [

            'Identify the ordering the problem requires.',

            'Choose a sorting strategy appropriate for the data.',

            'After sorting, the candidates can be processed in the required order.',

          ],

          concepts: ['Sorting', 'Comparison', 'Arrays'],

          hints: [

            'What property should the final array have?',

            'Think about comparing elements and arranging them according to their values.',

            'Consider the standard sorting algorithms you have learned.',

          ],

          timeComplexity: 'O(n log n)',

          spaceComplexity: 'O(n)',

        );

      case 6:

        return const LevelContent(

          title: 'LINKED CHAIN',

          subtitle: 'Repair the candidate chain',

          problem:

              'Candidates are stored as nodes connected one after another. '

              'You need to understand how to move through this chain and locate a particular candidate.',

          exampleInput: '10 → 20 → 30 → 40, target = 30',

          exampleOutput: 'Found at position 3',

          intuition: [

            'Each node knows where the next node is.',

            'Start from the first node and follow the links one by one.',

            'Stop when the required value is found or the chain ends.',

          ],

          concepts: ['Linked List', 'Nodes', 'Traversal'],

          hints: [

            'Can you jump directly to an arbitrary node?',

            'Start at the head and follow the next reference.',

            'Continue until the value is found or the pointer becomes null.',

          ],

          timeComplexity: 'O(n)',

          spaceComplexity: 'O(1)',

        );

      case 7:

        return const LevelContent(

          title: 'STACK FORTRESS',

          subtitle: 'Process candidates in order',

          problem:

              'A system receives a sequence of operations where the most recently '

              'added item must be processed first. Identify the data structure that fits this behavior.',

          exampleInput: 'Push A, Push B, Pop',

          exampleOutput: 'B',

          intuition: [

            'Focus on which item should leave the structure first.',

            'The newest item is removed before older items.',

            'Identify the data structure that follows this ordering rule.',

          ],

          concepts: ['Stack', 'LIFO', 'Push / Pop'],

          hints: [

            'Which item is removed first: the oldest or newest?',

            'Think about Last In, First Out.',

            'A stack provides exactly this behavior.',

          ],

          timeComplexity: 'O(1)',

          spaceComplexity: 'O(n)',

        );

      case 8:

        return const LevelContent(

          title: 'RECURSION DUNGEON',

          subtitle: 'Break the problem into smaller quests',

          problem:

              'A problem can be solved by repeatedly solving a smaller version '

              'of the same problem. Identify the key structure required to make this approach work safely.',

          exampleInput: 'factorial(4)',

          exampleOutput: '24',

          intuition: [

            'Look for a problem that contains a smaller version of itself.',

            'Define how the current problem depends on a smaller problem.',

            'Identify the condition that stops the repeated calls.',

          ],

          concepts: ['Recursion', 'Base Case', 'Call Stack'],

          hints: [

            'What smaller version of the problem can solve the current one?',

            'Every recursive approach needs a stopping condition.',

            'Find the base case before thinking about the recursive step.',

          ],

          timeComplexity: 'O(n)',

          spaceComplexity: 'O(n)',

        );

      case 9:

        return const LevelContent(

          title: 'TREE KINGDOM',

          subtitle: 'Navigate the hierarchy',

          problem:

              'Candidates are organized in a hierarchical structure. '

              'You need to understand how to visit nodes according to a specific traversal order.',

          exampleInput: 'Root: 4, Left: 2, Right: 6',

          exampleOutput: '2, 4, 6',

          intuition: [

            'A tree has relationships between parent and child nodes.',

            'Traversal means deciding the order in which nodes are visited.',

            'Choose the traversal based on the required output order.',

          ],

          concepts: ['Trees', 'Traversal', 'Binary Search Tree'],

          hints: [

            'Which node should be visited first in the required order?',

            'For sorted output from a BST, think about the appropriate traversal.',

            'In-order traversal visits left, root, then right.',

          ],

          timeComplexity: 'O(n)',

          spaceComplexity: 'O(n)',

        );

      case 10:

        return const LevelContent(

          title: 'GRAPH BOSS',

          subtitle: 'Find the safest route',

          problem:

              'A placement network contains multiple connected locations. '

              'Find an efficient way to explore the network and reason about reaching a destination.',

          exampleInput: 'A → B → C, A → D → C',

          exampleOutput: 'A path to C exists',

          intuition: [

            'Represent the locations as vertices and connections as edges.',

            'Start from the source and explore connected locations.',

            'Choose a graph traversal or shortest-path technique based on the question.',

          ],

          concepts: ['Graphs', 'BFS / DFS', 'Shortest Path'],

          hints: [

            'What are the vertices and what are the edges?',

            'For simple reachability, think about BFS or DFS.',

            'If edge weights matter, consider a shortest-path algorithm.',

          ],

          timeComplexity: 'O(V + E)',

          spaceComplexity: 'O(V)',

        );

      default:

        return const LevelContent(

          title: 'NEW QUEST',

          subtitle: 'A new challenge awaits',

          problem: 'This level is being prepared.',

          exampleInput: 'Coming soon',

          exampleOutput: 'Coming soon',

          intuition: [

            'Break the problem into smaller parts.',

            'Identify the information you need.',

            'Choose the appropriate concept.',

          ],

          concepts: ['Problem Solving'],

          hints: [

            'Start by understanding the input.',

            'Identify the expected output.',

            'Think about the most suitable approach.',

          ],

          timeComplexity: 'TBD',

          spaceComplexity: 'TBD',

        );

    }

  }

}

class _TwoSumAnimation extends StatefulWidget {
  const _TwoSumAnimation();

  @override
  State<_TwoSumAnimation> createState() => _TwoSumAnimationState();
}

class _TwoSumAnimationState extends State<_TwoSumAnimation> {
  static const numbers = [2, 7, 11, 15];
  static const target = 9;

  int step = 0;
  bool playing = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (playing) {
      _timer?.cancel();
      setState(() => playing = false);
      return;
    }
    if (step >= 4) setState(() => step = 0);
    setState(() => playing = true);
    _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      if (step >= 4) {
        _timer?.cancel();
        setState(() => playing = false);
      } else {
        setState(() => step++);
      }
    });
  }

  void _next() {
    _timer?.cancel();
    setState(() {
      playing = false;
      if (step < 4) step++;
    });
  }

  void _previous() {
    _timer?.cancel();
    setState(() {
      playing = false;
      if (step > 0) step--;
    });
  }

  void _replay() {
    _timer?.cancel();
    setState(() {
      step = 0;
      playing = false;
    });
  }

  String get _message {
    switch (step) {
      case 0:
        return 'Target = 9. Start with 2. Its complement is 7.';
      case 1:
        return 'Store 2 in memory, then move to the next value.';
      case 2:
        return 'For 7, the complement is 9 - 7 = 2. We already stored 2!';
      case 3:
        return 'The matching pair is found. No need to scan the remaining values.';
      default:
        return 'Result: [2, 7] — because 2 + 7 = 9.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_LevelDetailScreenState>();
    final accent = state?.widget.accentColor ?? const Color(0xFF22D3EE);
    final found = step >= 2;
    final activeIndex = step <= 1 ? step : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ARRAY', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              Text('TARGET = $target', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(numbers.length, (i) {
              final isActive = !found && i == activeIndex;
              final isPair = found && (i == 0 || i == 1);
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: i == numbers.length - 1 ? 0 : 7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: (isActive || isPair) ? accent.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (isActive || isPair) ? accent.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Column(
                    children: [
                      Text('${numbers[i]}', style: TextStyle(color: (isActive || isPair) ? Colors.white : Colors.white70, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text('[$i]', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(_message, key: ValueKey(step), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: step > 0 ? _previous : null, icon: const Icon(Icons.skip_previous_rounded), color: Colors.white),
              IconButton(onPressed: _togglePlay, icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded), color: accent, iconSize: 32),
              IconButton(onPressed: step < 4 ? _next : null, icon: const Icon(Icons.skip_next_rounded), color: Colors.white),
              IconButton(onPressed: _replay, icon: const Icon(Icons.replay_rounded), color: Colors.white70),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final selected = i == step;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 12 : 8,
                height: selected ? 12 : 8,
                decoration: BoxDecoration(color: selected ? accent : Colors.white24, shape: BoxShape.circle),
              );
            }),
          ),
        ],
      ),
    );
  }
}

