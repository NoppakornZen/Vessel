# Vessel: Action Story-Driven RPG (2D Dark Fantasy)

### [TH] เกี่ยวกับเกม
**"Vessel"** มีความหมายว่า "เรือ" หรือ "ภาชนะ" ซึ่งเข้ากับธีม Dark Fantasy ของเกมที่ถ่ายทอดอารมณ์ของ "คนที่เป็นภาชนะของอะไรบางอย่าง" โดยผู้เล่นจะรับบทเป็น **Zon** นักเรียนธรรมดาที่หลงเข้าไปในโลกลึกลับและต้องหาทางกลับบ้านให้ได้

**[EN] About the Game**
"Vessel" refers to both a ship and a container, fitting the Dark Fantasy theme where the protagonist is a "vessel" for something mysterious. Players play as **Zon**, an ordinary student lost in an unknown world, struggling to find his way back home.

---

### [TH] ระบบเด่นภายในเกม (Key Features)
* **ระบบบทสนทนา (Textbox)**: เพื่อให้ผู้เล่นอินไปกับการเดินทางของ Zon
* **ระบบการต่อสู้**: มีระบบเลือด (HP) ของทั้งผู้เล่นและศัตรู เช่น Slime และ Boss
* **ระบบ Y-Sort (การจัดลำดับภาพ)**: ใช้ค่าพิกัดแนวตั้ง (แกน Y) กำหนดการวาดทับของวัตถุเพื่อให้เกมดูมีมิติสมจริง

**[EN] Key Features**
* **Dialogue System**: Enhances immersion in Zon's journey.
* **Combat System**: HP management for Zon and various enemies (Slimes/Bosses).
* **Y-Sort Implementation**: Dynamically manages rendering layers based on Y-axis coordinates for realistic 2D depth.

---

### [TH] ความภูมิใจในเชิงเทคนิค (Technical Pride)
สิ่งที่ภูมิใจที่สุดคือการแก้ปัญหา **Y-Sort** ซึ่งมีความซับซ้อนในการจัดการลำดับการวาดภาพ (Rendering) การคำนวณพิกัดแกน Y เพื่อให้วัตถุซ้อนทับกันอย่างถูกต้องทำให้ผมเข้าใจตรรกะการจัดการข้อมูลเชิงพื้นที่ในเกมมากขึ้น เเละการเเก้ไข Code ที่ AI ให้มาโดยที่ไม่สมบูรณ์ ทำให้ผมได้เข้าใจว่า AI เป็นเเค่ผู้ช่วยของเรา อย่างที่เราคิดเอาไว้

**[EN] Technical Pride**
My greatest achievement was implementing the **Y-Sorting logic**. It required a deep understanding of rendering orders and spatial data management, ensuring all entities appear correctly in a 2D environment And fixing the incomplete code provided by the AI ​​made me understand that AI is just an assistant, as we initially thought.
