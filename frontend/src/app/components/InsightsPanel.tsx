interface Insight {
  id: string;
  name: string;
  value: number;
}

export function InsightsPanel({ insights }: { insights: Insight[] }) {
  return (
    <section className="mb-8">
      <h2 className="text-xl font-semibold mb-4">Insights</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {insights.map((insight) => (
          <div
            key={insight.id}
            className="border rounded-lg p-4 bg-gray-50 dark:bg-gray-800"
          >
            <p className="text-sm text-gray-600 dark:text-gray-400 font-mono">
              {insight.name}
            </p>
            <p className="text-2xl font-bold mt-1">
              {typeof insight.value === 'number' && insight.value < 1 && insight.value > 0
                ? `${(insight.value * 100).toFixed(2)}%`
                : insight.value.toLocaleString()}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
