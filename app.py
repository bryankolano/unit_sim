
from dash import Dash, html, dcc, Input, Output, dash_table
import plotly.express as px
import pandas as pd
from unit_sim import simulation

app = Dash(__name__)

    
df = pd.read_excel('data.xlsx', engine = 'openpyxl')
df = df.reset_index(drop = True)


app.layout = html.Div([
    html.H1('Dashboard for Army Unit Simulation',style = {'text-align': 'center'}),
    html.H2('By: Bryan Kolano',style = {'text-align': 'center'}),
    html.H4("This simple dashboard allows a particular Army unit to study and assess the future of their ranks.",style = {'text-align': 'center'}),
    html.H4("With this dashboard, the unit can change various inputs and see how it impacts the unit's manning numbers in the future.",style = {'text-align': 'center'}),
    html.H4("The unit can then make personnel and recruitment decisions to better influence the size of the unit in the future.",style = {'text-align': 'center'}),
    
    
    #overall left side
    html.Div([
        #left left
        html.Div([
            html.H3('Number of Sims'),
            dcc.Input(id = 'num_of_sims', min=1, max=100, value = 50, step=1, type = 'number'),
            html.H3('LTC Promotion Rate'),
            dcc.Input(id = 'ltc_prob', min=.15, max=1,  value = .66, step=.01, type = 'number'), 
            ],style={'width': '48%', 'float': 'left','text-align': 'center'}),
        #'right left'
        html.Div([
            html.H3('COL Promotion Rate'),
            dcc.Input(id = 'col_prob', min=.15, max=1, value = .25, step=.01, type = 'number'),
            html.H3('MAJ Promotion Rate'),
            dcc.Input(id = 'maj_prob', min=.15, max=1, value = .80,  step=.01, type = 'number'),
        ],style={'width': '48%', 'float': 'right','text-align': 'center'}),
        html.Div([
                dash_table.DataTable(
                id='new_officer_table',
                columns=[
                    {"name": "Year", 'id':'Year', "deletable": False, "editable": False},
                    {"name": "Captains", 'id':'Captains', "editable": True},
                    {"name": "Majors", 'id':'Majors', "editable": True}
                ],
                data=[
                    {
                        "Year": i,
                        "Captains": 1,
                        "Majors": 2
                    }
                    for i in range(1,11)
                    ],
                editable=True
                )
                
            ], style = {'text-align':'center'}),    
        
        
        
    ],style={'width': '39%', 'float': 'left', 'display': 'inline-block'}),

    #black line
    html.Div([],style = {  'border-left': '5px solid black', 'height': '900px', 'position': 'absolute', 'left': '41%', 'margin-left': '-3px', 'top': '30%'}),
    
    #right side
    html.Div([
         html.H2('Select the visualization you would like to view.', style = {'text-align': 'center'}),
         dcc.Tabs(id = "sim_graphs", value = 'tab_1_graph', children = [
            dcc.Tab(label = "Box Plots", value = 'tab_1_graph'),
            dcc.Tab(label = 'Column Plot', value = 'tab_2_graph')
         ]),
         dcc.Graph(id = 'graph_output')


    ],style={'width': '58%', 'float': 'right', 'display': 'inline-block'})
    ])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@app.callback(
    Output('graph_output', 'figure'),
    Input('num_of_sims', 'value'),
    Input('new_officer_table', 'data'),
    Input('new_officer_table','columns'),
    Input('col_prob', 'value'),
    Input('ltc_prob', 'value'),
    Input('maj_prob', 'value'),
    Input('sim_graphs', 'value'))

def update_graph(sims, new_officer_table,columns, col, ltc, maj, graphs):

    new_officers = pd.DataFrame(new_officer_table, columns = [c['name'] for c in columns])
    new_officers = new_officers.astype(int)
    cpts = new_officers.iloc[:,1]
    majs = new_officers.iloc[:,2]
  
    
    sim_results = simulation(df= df, num_of_sims= sims, new_majs= majs,
                            new_cpts= cpts, col_prob= col, ltc_prob=ltc,
                            maj_prob = maj)

    avg_rank_by_year = sim_results.groupby(['Rank','Year']).mean().reset_index()
    if graphs == 'tab_1_graph':
        fig = px.box(sim_results, x="Year", y="Quantity", facet_row="Rank", 
                    title = 'Box Plots of Populations Across 10 Years',width=900, height=900,
                    color = 'Rank',
                    labels=dict(Quantity="Number of Officers")
                    )

        fig.update_xaxes(matches=None)
        fig.for_each_xaxis(lambda xaxis: xaxis.update(showticklabels=True))

        fig.update_yaxes(matches=None)

        fig.update_layout(
            xaxis = dict(
            tickmode = 'linear',
            tick0 = 2022,
            dtick = 1
            ))

        return fig

    elif graphs == 'tab_2_graph':
        fig = px.box(sim_results, x="Year", y="Quantity", facet_row="Rank", 
            title = 'checker',width=1000, height=1000,
            color = 'Rank',
            labels=dict(Quantity="Number of Officers")
            )

        fig = px.histogram(sim_results, x="Year", y="Quantity", 
                 color="Rank", title = "Bar Plot of Population Across 10 years",
                 width=900, height=900,
                 labels=dict(Quantity="Number of Officers"),
                 barmode="group")
        
        fig.update_layout(
            xaxis = dict(
            tickmode = 'linear',
            tick0 = 2022,
            dtick = 1
            )
            )



        return fig
    


if __name__ == '__main__':
    app.run_server(debug=True)
