import 'dart:html';
import 'dart:math';

final colors = ['orange', 'darkblue', 'red', 'green', 'blue', 'purple', 'yellow', 'turquoise', 'gray'];
final random = new Random();

void main() {
  Block outer = new Block(0,0,2,2);
  Block inner = new Block(1,1,1,1);

  assert(inner.isInside(outer));
  assert(! outer.isInside(inner));
  assert(inner.overlaps(outer));
  assert(outer.overlaps(inner));

  generateTiles(null);
  querySelector("#generate")
    ..onClick.listen(generateTiles);
}

const SIZE = 150;
const RANDOMS = 2;
const NUMBER = 30;

void generateTiles(MouseEvent event) {
  Tetris tetris = new Tetris((900 / SIZE).round(), (700 / SIZE).round());

  int colorNumber = random.nextInt(colors.length);
  DivElement tiles = querySelector("#tiles");
  tiles.children.clear();

  for(num i = 0; i < NUMBER; i++) {
    Block block = new Block(0, 0, random.nextInt(RANDOMS) + 1, random.nextInt(RANDOMS) + 1);

    if(tetris.place(block)) {
      tiles.append(createBlock(block, i, colorNumber++));
    }

  }
  tiles.style.height = '${tetris.playHeight() * SIZE}px';
}

DivElement createBlock(Block block, num i, int colorNumber) {
  DivElement div = new DivElement();
  div.style
    ..position = 'absolute'
    ..margin = '0 10px 10px 0'
    ..backgroundColor = colors[colorNumber++ % colors.length]
    ..width = '${block.width * SIZE - 10}px'
    ..height = '${block.height * SIZE - 10}px'
    ..left = '${block.x * SIZE + 10}px'
    ..top = '${block.y * SIZE + 10}px';
  
  DivElement num = new DivElement()
    ..classes.add('num')
    ..text = i.toString();
  
  div.append(num);
  return div;
}

var containers = [];

class Block {
  int x, y;
  int width, height;
  Block(this.x, this.y, this.width, this.height);

  overlaps(Block other) {
    return (other.x < (this.x + this.width) && (other.x + other.width) > this.x) &&
      (other.y < (this.y + this.height) && (other.y + other.height) > this.y);
  }

  isInside(Block other) {
    return (other.x <= this.x && (other.x + other.width) >= (this.x + this.width)) &&
      (other.y <= this.y && (other.y + other.height) >= (this.y + this.height));
  }
}

class Tetris extends Block {
  List<Block> blocks = [];
  Tetris(int width, int height) : super(0, 0, width, height);

  bool place(Block block) {
    if(block.isInside(this)) {
      if(findPlace(block)) {
        blocks.add(block);
        return true;
      }
    }
    return false;
  }

  bool findPlace(Block block) {
    while(hasOverlap(block)) {
      if(! moveBlock(block)) {
        return false;
      }
    }
    return true;
  }

  bool hasOverlap(Block block) {
    for(Block playBlock in blocks) {
      if(playBlock.overlaps(block)) {
        return true;
      }
    }
    return false;
  }

  bool moveBlock(Block block) {
    block.x += 1;
    if(block.x + block.width > this.x + this.width) {
      block.x = 0;
      block.y += 1;
      if(block.y + block.height > this.y + this.height) {
        return false;
      }
    }
    return true;
  }

  int playHeight() {
    var height = 0;
    for(Block block in blocks) {
      height = max(height, block.y + block.height);
    }
    return height;
  }
}