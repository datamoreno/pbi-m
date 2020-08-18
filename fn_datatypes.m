( nometabela as table) =>
let

// Prefixos.
    pfx_nomestxt = {"ID", "DS", "NM"},
    pfx_decimais = {"VL"},
    pfx_percento = {"VP"},
    pfx_dinheiro = {"VM", "R$"},
    pfx_inteiros = {"CD", "KEY", "QT"},
    pfx_so_datas = {"DT"},
    pfx_datahora = {"DTH"},

// Nomes Originais.
    tb_original = nometabela,
    ls_original = Table.ColumnNames(tb_original),

// Converter para Maiúsculo
// Pode ser retirado, mas o M é casesensitive, então os prefixos podem precisar ser tratados.
    ls_upper = List.Transform(ls_original, each {_, Text.Upper(_)}),
    tb_upper = Table.RenameColumns(tb_original,ls_upper),

// Funcao para retornar apenas  a parte do nome das colunas antes do UnderLine
	fn_prefixnames =
	(
	     (colunas as text)=> 
	    let 
	    tb_colunas = Text.Split(colunas,"_"),
	    ls_colunas = tb_colunas{0}
	    in
	    {ls_colunas} 
        //precisa colocar as chaves para retornar como tipo lista
        //senao dá problema quando só tem um item

	),

// Função para mudar o datatype das colunas.
    fn_column =
    (
        (tabela as table, prefixo as list, tipocoluna as type) => 
        let 
      	//ls_underline = List.Transform(prefixo, each {_ & Character.FromNumber(95) }), 
      	// a linha acima adiciona um underline no final de cada prefixo
      	// acabei substituindo por uma fn, mas mantive o histórico
        ls_colunapfx = List.Select(Table.ColumnNames(tabela), each List.ContainsAny(prefixo,fn_prefixnames(_))),
        ls_conversao = List.Transform(ls_colunapfx, each {_, tipocoluna}),
        tb_conversao = Table.TransformColumnTypes(tabela,ls_conversao)
        in
        tb_conversao
    ),

// Executar as funcoes para cada tipo de dados.
// Ainda quero evoluir esse trecho para fazer esse change em loop
    tb_change1 = fn_column(tb_upper  , pfx_nomestxt, Text.Type       ),
    tb_change2 = fn_column(tb_change1, pfx_decimais, Decimal.Type   ),
    tb_change3 = fn_column(tb_change2, pfx_percento, Percentage.Type),
    tb_change4 = fn_column(tb_change3, pfx_dinheiro, Currency.Type  ),
    tb_change5 = fn_column(tb_change4, pfx_inteiros, Int64.Type     ),
    tb_change6 = fn_column(tb_change5, pfx_so_datas, Date.Type      ),
    tb_change7 = fn_column(tb_change6, pfx_datahora, DateTime.Type  )

in
    tb_change7
