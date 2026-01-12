"""
    Read in file line by line, for each line if L subtract, if R add. Every time total == 0, count++
"""
debugon = True

def lazy_open_read(filename):
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line: yield line[0], int(line[1:])   

def day1pt1(in_filename, dial_width):
    with open(in_filename, 'r') as f:
        total = 50
        cnt = 0
        turn = 0
        for direction, amnt in lazy_open_read(in_filename):
            if (debugon): print(f'sum total {total} turn amnt {amnt} direction {direction} \n cnt total {cnt}')
            if direction == 'L': total = (total - amnt) % dial_width
            else:   total = (total + amnt) % dial_width

            if total == 0: cnt += 1
        return cnt

def pythonic_d1pt2(in_filename, dial_width):
    total = 50
    cnt = 0
    tail = 0
    for direction, amnt in lazy_open_read(in_filename):
        cnt += (amnt//dial_width) # account for full rotations of dial width, e.g. if R1000 and total=50 then will be 10
        tail = amnt%dial_width

        if direction == 'L':
            if 0 < total <= tail: cnt += 1 # if total is not at 0 (since that would've been counted by the previous read) and tail to move >= that, will cross 0 once
        else:
            if total + tail >= dial_width: cnt +=1
        
        total = (total - amnt)%dial_width if direction == 'L' else (total + amnt)%dial_width 
    return cnt

def main():
    res1 = day1pt1('in.txt', 100)
    print(f'day1pt1 sol: {res1}')

    res2 = pythonic_d1pt2('in.txt', 100)
    print(f'day1pt2 sol {res2}')

if __name__ == "__main__":
    main()