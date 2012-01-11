Raphael.fn.g.piechart = function(e, d, q, b, l) {
    l = l || {};
    var k = this,n = [],g = this.set(),o = this.set(),j = this.set(),v = [],x = b.length,y = 0,B = 0,A = 0,c = 9,z = true;
    o.covers = g;
    if (x == 1) {
        j.push(this.circle(e, d, q).attr({fill:this.g.colors[0],stroke:l.stroke || "#fff","stroke-width":l.strokewidth == null ? 1 : l.strokewidth}));
        g.push(this.circle(e, d, q).attr(this.g.shim));
        B = b[0];
        b[0] = {value:b[0],order:0,valueOf:function() {
            return this.value
        }};
        j[0].middle = {x:e,y:d};
        j[0].mangle = 180
    } else {
        function u(G, F, i, I, E, N) {
            var K = Math.PI / 180,C = G + i * Math.cos(-I * K),p = G + i * Math.cos(-E * K),H = G + i / 2 * Math.cos(-(I + (E - I) / 2) * K),M = F + i * Math.sin(-I * K),L = F + i * Math.sin(-E * K),D = F + i / 2 * Math.sin(-(I + (E - I) / 2) * K),J = ["M",G,F,"L",C,M,"A",i,i,0,+(Math.abs(E - I) > 180),1,p,L,"z"];
            J.middle = {x:H,y:D};
            return J
        }

        for (var w = 0; w < x; w++) {
            B += b[w];
            b[w] = {value:b[w],order:w,valueOf:function() {
                return this.value
            }}
        }
        b.sort(function(p, i) {
            return i.value - p.value
        });
        for (w = 0; w < x; w++) {
            if (z && b[w] * 360 / B <= 1.5) {
                c = w;
                z = false
            }
            if (w > c) {
                z = false;
                b[c].value += b[w];
                b[c].others = true;
                A = b[c].value
            }
        }
        x = Math.min(c + 1, b.length);
        A && b.splice(x) && (b[c].others = true);
        for (var w = 0; w < x; w++) {
            var m = b[w].order;
            var f = y - 360 * b[w] / B / 2;
            if (!w) {
                y = 90 - f;
                f = y - 360 * b[w] / B / 2
            }
            if (l.init) {
                var h = u(e, d, 1, y, y - 360 * b[w] / B).join(",")
            }
            var t = u(e, d, q, y, y -= 360 * b[w] / B);
            var s = this.path(l.init ? h : t).attr({fill:l.colors && l.colors[m] || this.g.colors[m] || "#666",stroke:l.stroke || "#fff","stroke-width":(l.strokewidth == null ? 1 : l.strokewidth),"stroke-linejoin":"round"});
            s.value = b[w];
            s.middle = t.middle;
            s.mangle = f;
            n.push(s);
            j.push(s);
            l.init && s.animate({path:t.join(",")}, (+l.init - 1) || 1000, ">")
        }
        for (var w = 0; w < x; w++) {
            var m = b[w].order;
            var s = k.path(n[w].attr("path")).attr(this.g.shim);
            l.href && l.href[m] && s.attr({href:l.href[m]});
            s.attr = function() {
            };
            g.push(s);
            j.push(s)
        }
    }
    o.hover = function(D, r) {
        r = r || function() {
        };
        var C = this;
        for (var p = 0; p < x; p++) {
            (function(E, F, i) {
                var G = {sector:E,cover:F,cx:e,cy:d,mx:E.middle.x,my:E.middle.y,mangle:E.mangle,r:q,value:b[i],total:B,label:C.labels && C.labels[i]};
                F.mouseover(
                        function() {
                            D.call(G)
                        }).mouseout(function() {
                    r.call(G)
                })
            })(j[p], g[p], p)
        }
        return this
    };
    o.each = function(C) {
        var r = this;
        for (var p = 0; p < x; p++) {
            (function(D, E, i) {
                var F = {sector:D,cover:E,cx:e,cy:d,x:D.middle.x,y:D.middle.y,mangle:D.mangle,r:q,value:b[i],total:B,label:r.labels && r.labels[i]};
                C.call(F)
            })(j[p], g[p], p)
        }
        return this
    };
    o.click = function(C) {
        var r = this;
        for (var p = 0; p < x; p++) {
            (function(D, E, i) {
                var F = {sector:D,cover:E,cx:e,cy:d,mx:D.middle.x,my:D.middle.y,mangle:D.mangle,r:q,value:b[i],total:B,label:r.labels && r.labels[i]};
                E.click(function() {
                    C.call(F)
                })
            })(j[p], g[p], p)
        }
        return this
    };
    o.inject = function(i) {
        i.insertBefore(g[0])
    };
    var a = function(H, C, r, p) {
        var L = e + q + q / 5,K = d,G = K + 10;
        H = H || [];
        p = (p && p.toLowerCase && p.toLowerCase()) || "east";
        r = k.g.markers[r && r.toLowerCase()] || "disc";
        o.labels = k.set();
        for (var F = 0; F < x; F++) {
            var M = j[F].attr("fill"),D = b[F].order,E;
            b[F].others && (H[D] = C || "Others");
            H[D] = k.g.labelise(H[D], b[F], B);
            o.labels.push(k.set());
            o.labels[F].push(k.g[r](L + 5, G, 5).attr({fill:M,stroke:"none"}));
            o.labels[F].push(E = k.text(L + 20, G, H[D] || b[D]).attr(k.g.txtattr).attr({fill:l.legendcolor || "#000","text-anchor":"start"}));
            g[F].label = o.labels[F];
            G += E.getBBox().height * 1.2
        }
        var I = o.labels.getBBox(),J = {east:[0,-I.height / 2],west:[-I.width - 2 * q - 20,-I.height / 2],north:[-q - I.width / 2,-q - I.height - 10],south:[-q - I.width / 2,q + 10]}[p];
        o.labels.translate.apply(o.labels, J);
        o.push(o.labels)
    };
    if (l.legend) {
        a(l.legend, l.legendothers, l.legendmark, l.legendpos)
    }
    o.push(j, g);
    o.series = j;
    o.covers = g;
    return o
};
