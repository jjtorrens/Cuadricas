# coding: utf-8
def Catalogo_cuadricas():
    from collections import OrderedDict
    var("x,y,z")
    cuad = OrderedDict()
    cuad["Elipsoide"] \
        = dict(ec=(x^2/9+y^2/4+z^2==1), caja=[-3.2, 3.2, -2.2, 2.2, -1.1, 1.1])
    cuad["Hiperboloide de una hoja"] \
        = dict(ec=(x^2+y^2-z^2/4==1), caja=[-1.5, 1.5, -1.5, 1.5, -2.2, 2.2])
    cuad["Hiperboloide de dos hojas"] \
        = dict(ec=(x^2+y^2-z^2/0.64==-1), caja=[-1.8, 1.8, -1.8, 1.8, -1.6, 1.6])
    cuad["Cono"] \
        = dict(ec=(x^2+y^2==z^2/4), caja=[-1.5, 1.5, -1.5, 1.5, -2.2, 2.2])
    cuad[u"Paraboloide elíptico"] \
        = dict(ec=(x^2+y^2==z), caja=[-1.5, 1.5, -1.5, 1.5, -0.2, 2.2])
    cuad[u"Paraboloide hiperbólico"] \
        = dict(ec=(x^2-y^2==z), caja=[-1.5, 1.5, -1.5, 1.5, -2.4, 2.4])
    cuad[u"Cilindro elíptico"] \
        = dict(ec=(x^2+y^2==1), caja=[-1.5, 1.5, -1.5, 1.5, -2.2, 2.2])
    cuad[u"Cilindro parabólico"] \
        = dict(ec=(x^2==y), caja=[-1.5, 1.5, -0.5, 1.5, -2.2, 2.2])
    cuad[u"Cilindro hiperbólico"] \
        = dict(ec=(x^2-y^2==1), caja=[-1.5, 1.5, -1.5, 1.5, -2.2, 2.2])    

    @interact
    def _(cuadrica=selector(list(cuad), label=u"Cuádrica"),
          marcar=checkbox(False, label="Marcar las trazas"),
          trazas=selector(["xy", "xz", "yz"], buttons=True, label="Trazas")):
        x1, x2, y1, y2, z1, z2 = cuad[cuadrica]["caja"]
        fun = {"xy": lambda x,y,z: (z-z1)/(z2-z1), "xz": lambda x,y,z: (y-y1)/(y2-y1),
               "yz": lambda x,y,z: (x-x1)/(x2-x1)}
        color_sup = "green"
        if marcar: 
            color_sup = (fun[trazas], colormaps.jet)
        figura = implicit_plot3d(cuad[cuadrica]["ec"], (x,x1,x2), (y,y1,y2), (z,z1,z2), 
                             color=color_sup, viewer="threejs")
        dx, dy, dz = x2+0.5, y2+0.5, z2+0.5
        figura += arrow3d((0,0,0), (dx,0,0), color="gray") + text3d("x", (dx,0,0))
        figura += arrow3d((0,0,0), (0,dy,0), color="gray") + text3d("y", (0,dy,0))
        figura += arrow3d((0,0,0), (0,0,dz), color="gray") + text3d("z", (0,0,dz))
        figura.show(frame=False)
        
# ------------------------------------------------------------------------
# Función que genera los datos del problema de identificación de cuádricas
# Salida: ecuación implícita, ecuación en forma canónica, tipo, centro
def Generar_Problema():
    var("x,y,z,a,b,c")
    ecs = [x^2/a^2+y^2/b^2+z^2/c^2==1,
           x^2/a^2+y^2/b^2-z^2/c^2==1,
           x^2/a^2+y^2/b^2-z^2/c^2==-1,
           x^2/a^2+y^2/b^2-z^2/c^2==0,
           x^2/a^2+y^2/b^2==z,
           x^2/a^2-y^2/b^2==z,
           x^2/a^2+y^2/b^2==1,
           x^2/a^2==y,
           x^2/a^2-y^2/b^2==1]
    tipos = ["elipsoide", "hiperboloide de una hoja", "hiperboloide de dos hojas",
             "cono", "paraboloide elíptico", "paraboloide hiperbólico",
             "cilindro elíptico", "cilindro parabólico",
             "cilindro hiperbólico"]
    # Elegimos aleatoriamente una permutación de las variables y una cuádrica
    tipo = randint(0,8)
    aa, bb, cc = random_vector(3, x=1, y=6)     # enteros entre 1 y 6
    x0, y0, z0 = random_vector(3 ,x=-3, y=3)    # enteros entre -3 y 3
    if tipo>=6: z0 = 0                          # z0 no influye en los cilindros
    v = sample([x-x0,y-y0,z-z0],3)

    # Transformamos la ecuación canónica
    ec1 = ecs[tipo].subs(a=aa, b=bb, c=cc, x=v[0], y=v[1], z=v[2])
    den = ec1.lhs().denominator()
    ec2 = den*ec1
    ec3 = expand(ec2.lhs()-ec2.rhs()==0)
    return ec1, ec3, tipos[tipo], x0, y0, z0

# ------------------------------------------------------------------------
# Función que presenta el panel para la identificación de cuádricas
# Hay un argumento booleano, Jupyter, para escoger si se evalúa el código
# en un cuaderno Jupyter
def Identificar_cuadricas(Jupyter=True):
    from IPython.display import clear_output
    var("x,y,z")
    # --- Panel 1: control para activar la generación de un nuevo problema
    @interact
    def panel_1(nuevo=selector(["Nuevo problema"], buttons=True, label=" ")):
        ec_ini, ec_fin, tipo, x0, y0, z0 = Generar_Problema()
        problema = "Determina de qué tipo es la cuádrica siguiente" \
                   + " y esboza su gráfica:"
        show(html("<hr><strong>Enunciado</strong>"))
        show(html(problema))
        show(ec_fin)
        show(html("<hr><strong>Solución</strong>"))
        
        # --- Panel 2: control para mostrar/ocultar la solución
        @interact
        def panel_2(mostrar=checkbox(label="Mostrar la solución", default=False)):
            if mostrar:
                show(html("Ecuación tras completar cuadrados:"))
                show(ec_ini)
                show(html("Se trata de un <strong>" + tipo + ".</strong>"))
                x1, x2 = x0-10, x0+10
                y1, y2 = y0-10, y0+10
                z1, z2 = z0-10, z0+10
                # --- Panel_3: controles de dibujo de la solución
                if Jupyter:
                    auto = False                            # cuaderno Jupyter
                else:
                    auto = UpdateButton(text="Actualizar")  # SageMath Cell
                @interact
                def panel_3(rx=range_slider(x0-15, x0+15, 0.5,
                                            default=(x0-10,x0+10), label="Rango $x$"),
                            ry=range_slider(y0-15, y0+15, 0.5, 
                                            default=(y0-10,y0+10), label="Rango $y$"),
                            rz=range_slider(z0-15, z0+15, 0.5, 
                                            default=(z0-10,z0+10), label="Rango $z$"),
                            color=color_selector(label="Color",default="green"),
                            auto_update=auto):
                    x1, x2 = rx
                    y1, y2 = ry
                    z1, z2 = rz
                    implicit_plot3d(ec_fin, (x,x1,x2), (y,y1,y2), (z,z1,z2), 
                                    color=color, viewer="threejs",figsize=3).show()
                # Modificamos la apariencia del panel 3 en un cuaderno Jupyter
                if Jupyter:
                    panel_3.widget.box_style = "success"
                    panel_3.widget.layout = dict(border="1px solid gray", padding="10px")
                    rx, ry, rz, color, auto, salida = panel_3.widget.children
                    for i in [rx,ry,rz]:
                        i.style.description_width = "4em"
                        i.layout.width = "70%"
                        i.readout_format="4.1f"
                    color.style.description_width = "4em"
                    auto.description = "Actualizar"
                    auto.button_style = "info"
                # --- fin del panel 3 ---
            else:
                clear_output()
        if Jupyter:
            panel_2.widget.box_style = "warning"
            panel_2.widget.layout = dict(border="1px solid gray", padding="10px")
            panel_2.widget.children[0].style.description_width = "0px"
        # --- fin del panel 2 ---
    if Jupyter:
        panel_1.widget.children[0].button_style = "info"
        panel_1.widget.children[0].style={"description_width": "0px",
                                          "button_width": "15em", "font_weight": "bold"}
    # --- fin del panel 1 ---