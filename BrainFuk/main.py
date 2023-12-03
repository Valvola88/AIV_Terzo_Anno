from reel import reel as rl

class Compiler():
    def read_text(text, tape_len = 10, debug = True):

        eng_text = ""
        tape = rl(tape_len)
        current_instruction = 0
        n = 0
        while current_instruction < len(text):
            command = text[current_instruction]
            if command in (" ","\n","\r","\t"):
                current_instruction += 1
                continue
            n+=1
            if command == "[":
                if tape.get_value() == 0:
                    while(text[current_instruction] != "]"):
                        current_instruction += 1
                else:
                    save_pointer = current_instruction
            elif command == "]":
                current_instruction = save_pointer
                continue
            rt = tape.command(command)
            if rt:
                eng_text += rt
            current_instruction += 1
        
        if debug ==True:
            print()
            print(n)
            print(tape.display_all_values())
        
        return eng_text

    def translate_extended(eng_text):
        returnable = ""
        for letter in eng_text:
            for b in range(ord(letter)):
                returnable+= "+"
            returnable+= ".>"
        return returnable

    def conver_letter(letter):
        return compact_all_plus(translate_extended(letter)).rstrip(".>")

    def smart_translate(eng_text):
        start = -1
        index = 0
        memory_slot = [0] * len(eng_text) * 2
        text=""
        #text += compact_all_plus(translate_extended(eng_text[0]))
        text += conver_letter(eng_text[0]) + ".\n"
        memory_slot[0] = ord(eng_text[0])
        pointer = 0
        max_pointer = 0

        for letter in eng_text[1:]:
            letter_commands = ""
            ascii_value = ord(letter)
            for p in range(len(memory_slot)):
                if ascii_value > memory_slot[p] - 10 and ascii_value < memory_slot[p] + 10:
                    letter_commands += ("<" if pointer - p > 0 else ">") * abs(pointer - p)

                    letter_commands += ("-" if ascii_value < memory_slot[p] else "+") * abs(ascii_value - memory_slot[p])
                    letter_commands += "."
                    memory_slot[p] = ascii_value

                    pointer = p
                    break
            
            if letter_commands == "":
                max_pointer = max_pointer + 2
                letter_commands += ">" * (max_pointer - pointer) + conver_letter(letter) + "."
                pointer = max_pointer
                memory_slot[pointer] = ord(letter)

                        

                
            text += letter_commands + "\n"
                

        #print(memory_slot)
        return text

    def compact_all_plus(long_text):
        if len(long_text) < 10:
            return
        
        start = -1
        lines = []
        index = 0
        text = long_text
        for c in long_text:
            if c == "+" and start < 0:
                start = index

            if (c != "+" and start >= 0):
                lines.append((start,index,replace_plus(long_text[start:index])))
                start = -1

            index += 1

        if len(lines) == 0: return long_text

        #print(lines)
        text = long_text[:lines[0][0]]
        for line in range(len(lines) - 1):
            text += lines[line][2]
            text += long_text[lines[line][1]:lines[line + 1][0]]

        text += lines[-1][2]
        text += long_text[lines[-1][1]:]
        #print(text)

        #print(lines)
        #for line in lines:
            #print(replace_plus(line))
            #pass

        return text

    def replace_plus(line):
        lenght = len(line)
        i = 3
        while i * i < lenght:
            i += 1
        j = i

        minimun = lenght

        real_values = (1,lenght, 0)

        #print((i,j))

        while i > 3:
            j = lenght // i
            while j > 3:
                if i * j > lenght:
                    j-=1
                    continue
                tmpval = (i + j + abs((i*j) -lenght) )
                #print("tmpval = " + str(tmpval))
                if tmpval < minimun:
                    real_values = (i, j, abs((i*j) -lenght))
                    minimun = tmpval
                j-=1
            i-=1

        
        #print(real_values)

        line = ">"
        line += "+" * real_values[0] 
        line += "[<" 
        line += "+" * real_values[1] 
        line += ">-]<" 
        line += "+" * real_values[2]

        return line

    #print(smart_translate("."))

    def file_handling_e_to_b():
        text = ""
        try:
            with open("input_english.txt", "r") as file:
                if file:
                    text = file.read()
        except:
        pass

        translation = ""
        if len(text) > 0:
            translation = smart_translate(text)

        #print(translation)
        with open("output_brainfuk.txt", "w+") as file:
            if text == "":
                file.write("Not found file 'input_english.txt'")
            else:
                file.write(translation)

    def file_handling_b_to_e():
        text = ""
        try:
            with open("input_brainfuk.txt", "r") as file:
                if file:
                    text = file.read()
        except:
            pass

        translation = read_text(text, 200, False)

        #print(translation)
        with open("output_english.txt", "w+") as file:
            file.write(translation)