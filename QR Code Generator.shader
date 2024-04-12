
//Enter numbers (0 - 1000000)
#define _S0 114514//pwde 
int text = int(_S0);//pwt

//Referenced sites
//https://www.nayuki.io/page/creating-a-qr-code-step-by-step
//https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders

//number of arrays
const int Ct = 19;
const int Cnsym = 7;
const int Ca = Ct + Cnsym;
const int gen = Cnsym + 1;

//converter n,v->c
int setc(int n, int v) {
    int nd = 1 << (8 - n);
    return (nd <= v * 2) ? v % nd * 2 / nd : 0;
}

//set position pattern
void sq(ivec2 p, ivec2 ss, ivec2 se, int v, inout int c) {
    if(all(lessThanEqual(ss, p)) && all(lessThanEqual(p, se)))
        c = v;
}
void corner(ivec2 p, ivec2 s, inout int c) {
    p -= s;
    s = sign(s);
    sq(p, ivec2(1), ivec2(8), 0, c);
    sq(p, 1 + s, 7 + s, 1, c);
    sq(p, 2 + s, 6 + s, 0, c);
    sq(p, 3 + s, 5 + s, 1, c);
}
//set zigzag data number
int ylen(int py, int l) {
    ivec2 se;
    if(l <= 4) {
        se = ivec2(0, 12);
    } else if(l <= 6) {
        se = ivec2(0, 20);
    } else {
        se = ivec2(8, 4);
    }
    py -= se.x;
    return (l % 2 == 1) ? py - 1 : se.y - py;
}
//data storage msg_in
void bytes(inout int nn, int v, int d, inout int msg_in[Ct], inout int intemp) {
    for(int i = d; 0 < i; i--) {
        int nt = 7 - (nn - 1) % 8;
        intemp += (1 << nt) * setc(8 - i, v);
        if(nt <= 0) {
            msg_in[(nn - 1) / 8] = intemp;
            intemp = 0;
        }
        nn += 1;
    }
}
//conversion from p to c (format information)
void ptoc(ivec2 p, ivec2 ss, ivec2 se, int fd, inout int c) {
    if(all(lessThanEqual(ss, p)) && all(lessThanEqual(p, se))) {
        ivec2 ps = p - ss;
        int n = ps.x + ps.y * (se.x - ss.x + 1);
        if(15 < p.y)
            n -= 1;
        c = setc(n, fd);
    }
}

//main
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    int i;
    int j;
    int k;
    //set positions
    vec2 p = fragCoord * 2.0 - iResolution.xy;
    p /= min(iResolution.x, iResolution.y);
    float f = float(abs(p.x) < 1.0 && abs(p.y) < 1.0);
    p = (p + 1.0) / 2.0;
    p = ceil(p * 21.0);
    p += vec2(step(p.x, 0.0), step(p.y, 0.0));
    ivec2 pbl = ivec2(p);
    ivec2 pul = ivec2(pbl.x, 22 - pbl.y);
    int c = -1;
    vec2 fpbr = vec2(22.0 - p.x, p.y);
    fpbr -= step(16.0, fpbr);
    ivec2 pbr = ivec2(fpbr);
    //set data number
    int l = (pbr.x + 1) / 2;
    int n = 24 * (clamp(l, 1, 5) - 1) + 40 * (clamp(l, 5, 7) - 5) + 8 * (clamp(l, 7, 10) - 7) + ylen(pbr.y, l) * 2 + (pbr.x + 1) % 2 + 1;
    int nn = 1;

    //Main data
    //mode(1,4)
    int intemp = 0;
    int msg_in[Ct];
    bytes(nn, 1, 4, msg_in, intemp);
    //count(count,10)
    float t = float(text);
    int digi = int(log2(t) / log2(10.0)) + 1;
    if(text == 0)
        digi = 1;
    bytes(nn, digi, 10, msg_in, intemp);
    //character data
    for(i = 1; i <= digi / 3 + 1; i++) {
        int ln = 3 * i - digi;
        ln = 3 - ln * int(0 <= ln);
        int dn = digi - (i - 1) * 3;
        int vn = int(mod(t, pow(10.0, float(dn))) / pow(10.0, float(dn - ln)));
        bytes(nn, vn, ln * 3 + 1, msg_in, intemp);
    }
    //terminator(0,4)
    bytes(nn, 0, 4, msg_in, intemp);
    //bit padding(0,nbit)
    int nbyte = (152 - nn + 1) / 8;
    int nbit = (152 - nn + 1) - nbyte * 8;
    bytes(nn, 0, nbit, msg_in, intemp);
    //byte padding(0xEC or 0x11,nbyte)
    for(i = 1; i <= nbyte; i++) {
        //EC,11,EC...
        int padding = (i % 2 == 1) ? 0xEC : 0x11;
        bytes(nn, padding, 8, msg_in, intemp);
    }
    //1-152

    //153-208(56)
    //Reed-Solomon error correction codes
    //generate gf_exp gf_log
    int gf_exp[512];
    int gf_log[256];
    int x = 1;
    for(i = 0; i < 255; i++) {
        gf_exp[i] = x;
        gf_log[x] = i;
        int y = 2;
        int r = 0;
        while(y != 0) {
            if((y & 1) != 0)
                r ^= x;
            y = y >> 1;
            x = x << 1;
            if(256 <= x)
                x ^= 0x11d;
        }
        x = r;
    }
    for(i = 255; i < 512; i++) {
        gf_exp[i] = gf_exp[i - 255];
    }
    //generate agen
    int agen[gen];
    int pl = 1;
    int ap[gen];
    int aq[2];
    agen[0] = 1;
    for(i = 0; i < Cnsym; i++) {
        ap = agen;
        aq = int[2] (1, gf_exp[(gf_log[2] * i) % 255]);
        pl += 1;
        for(j = 0; j < pl; j++) {
            agen[j] = 0;
        }
        for(j = 0; j < 2; j++) {
            for(k = 0; k < pl - 1; k++) {
                int x = ap[k];
                int y = aq[j];
                int gf_mul = (x == 0 || y == 0) ? 0 : gf_exp[gf_log[x] + gf_log[y]];
                agen[k + j] ^= gf_mul;
            }
        }
    }
    //generate msg_out
    int msg_out[Ca];
    for(i = 0; i < Ct; i++) {
        msg_out[i] = msg_in[i];
    }
    for(i = Ct; i < Ca; i++) {
        msg_out[i] = 0;
    }
    int msg_all[] = msg_out;
    for(i = 0; i < Ct; i++) {
        int coef = msg_out[i];
        if(coef != 0) {
            for(j = 1; j < gen; j++) {
                if(agen[j] != 0) {
                    int x = agen[j];
                    int y = coef;
                    int gf_mul = (x == 0 || y == 0) ? 0 : gf_exp[gf_log[x] + gf_log[y]];
                    msg_out[i + j] ^= gf_mul;
                }
            }
        }
    }
    for(i = Ct; i < Ca; i++) {
        msg_all[i] = msg_out[i];
    }
    if(c == -1) {
        c = setc((n - 1) % 8, msg_all[(n - 1) / 8]);
    }

    //Fixed patterns
    //set mask0
    if(c != -1) {
        int mf = abs(pbl.x % 2 - pbl.y % 2);
        c = (c == mf) ? 1 : 0;
    }
    //set format
    //11101111,11000100
    //0xEF,0xC4
    int fd1 = 0xEF;
    int fd2 = 0xC4;
    ptoc(pbl, ivec2(9, 1), ivec2(9, 8), fd1, c);
    ptoc(pbl, ivec2(14, 13), ivec2(21, 13), fd2, c);
    ptoc(pbl, ivec2(1, 13), ivec2(8, 13), fd1, c);
    ptoc(pbl, ivec2(9, 13), ivec2(9, 21), fd2, c);
    //set timing
    if(pul.x == 7 || pul.y == 7) {
        c = pul.x % 2 * pul.y % 2;
    }
    //set position pattern
    corner(pul, ivec2(0), c);
    corner(pul, ivec2(13, 0), c);
    corner(pul, ivec2(0, 13), c);

    //Output
    vec3 col = vec3(mix(0.5, float(1 - c), f));
    fragColor = vec4(col, 1.0);
}