<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

final class _activityCard extends CardBaseFramework
{
    private const PAGE_SIZE = 5;

    public function key(): string
    {
        return 'activity';
    }

    public function services(): array
    {
        return [];
    }

    public function handle(
        RequestFramework $request,
        PageServiceFramework $services,
        array $pageContext,
        ActionResultFramework $actionResult
    ): array {
        $pageContext = parent::handle($request, $services, $pageContext, $actionResult);
        $pageContext['page']['activity_window'] = $this->normaliseWindow((string)$request->input('activity_window', '7_days'));

        return $pageContext;
    }

    protected function additionalInvalidationFacts(): array
    {
        return ['dashboard.feed'];
    }

    public function handleError(string $serviceKey, array $error, array $context): string
    {
        return '';
    }

    public function render(array $context): string
    {
        $selectedWindow = $this->selectedWindow($context);
        return $this->configuredTable($context)->render($context, [
            'cards[]' => (array)($context['page']['page_cards'] ?? []),
            'activity_window' => $selectedWindow,
        ]);
    }

    public function tables(array $context): array
    {
        return [$this->table($context)];
    }

    private function configuredTable(array $context): TableFramework
    {
        $selectedWindow = $this->selectedWindow($context);
        $pagination = HelperFramework::paginateArray($this->rows($context), $this->paginationPage($context), self::PAGE_SIZE);

        return $this->table($context)
            ->visibleRows((array)$pagination['items'])
            ->pagination(
                $pagination,
                'Activity',
                $this->paginationPageField(),
                [
                    'page' => (string)($context['page']['page_id'] ?? ''),
                    '_pagination' => '1',
                    '_invalidate_fact' => $this->tableInvalidationFact(),
                    'cards[]' => [$this->key()],
                    'activity_window' => $selectedWindow,
                ]
            )
            ->filterSelect(
                'activity_window',
                'Window',
                $this->windowOptions(),
                $selectedWindow,
                [
                    'page' => (string)($context['page']['page_id'] ?? ''),
                    '_pagination' => '1',
                    '_invalidate_fact' => $this->tableInvalidationFact(),
                    'cards[]' => [$this->key()],
                ]
            );
    }

    private function table(array $context): TableFramework
    {
        return TableFramework::make($this->key(), $this->rows($context))
            ->filename('activity')
            ->exportLimit(500)
            ->empty('No audit or history events have been recorded yet.')
            ->column(
                'title',
                'Title',
                html: static fn(array $row): string => '<strong>' . HelperFramework::escape((string)($row['title'] ?? '')) . '</strong>',
                export: static fn(array $row): string => (string)($row['title'] ?? '')
            )
            ->textColumn('detail', 'Detail')
            ->textColumn('occurred_at', 'Time')
            ->textColumn('meta', 'Meta');
    }

    private function rows(array $context): array
    {
        $page = (array)($context['page'] ?? []);

        return array_values(array_filter(
            (array)(($context['services'] ?? [])['activity_feed'] ?? ($page['activity'] ?? [])),
            static fn(mixed $row): bool => is_array($row)
        ));
    }

    private function selectedWindow(array $context): string
    {
        $page = (array)($context['page'] ?? []);

        return $this->normaliseWindow((string)($page['activity_window'] ?? '7_days'));
    }

    private function windowOptions(): array
    {
        return [
            '1_day' => '1 day',
            '7_days' => '7 days',
            'this_month' => 'This month',
        ];
    }

    private function tableInvalidationFact(): string
    {
        return (string)($this->invalidationFacts()[0] ?? 'dashboard.feed');
    }

    private function normaliseWindow(string $window): string
    {
        return in_array($window, ['1_day', '7_days', 'this_month'], true) ? $window : '7_days';
    }
}
