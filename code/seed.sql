insert into users (username)
select 'user_' || gen_random_uuid() from generate_series(1, 15);

insert into plans (name, month_price, description)
values
('Standard', 4.9, '1 máquina e 300 capsulas'),
('Premium', 7.5, '2 máquina e 660 capsulas'),
('Platinum', 9.15, '3 máquina e 1320 capsulas'),
('Black', 10.8, '5 máquina e 1980 capsulas'),
('Infinity', 12.5, '10 máquina e 4000 capsulas')
;

insert into products (name, price)
values
('açucar 5g', 0.65),
('pazinha', 0.10),
('capsula sabores', 2.15),
('café em grãos tostados 1kg', 32.8),
('açucareiro', 12),
('leite em pó 500g', 4.2),
('achocolatado 1kg', 22)
;


--
-- Assinaturas aleatórias para cada usuário.
--
do $$
declare
	plan int;
	user_row record;
begin
	for user_row in
		select * from users
	loop
		select id from plans order by random() into plan;
	
		insert into signatures (user_id, plan_id)
		values (user_row.id, plan);
	end loop;
end; $$

--
-- compras e faturas aleatórias para os usuários
--

do $$
declare
    user_row record;
    invoice_row record;
    invoice_total decimal;
    plan_info record;
begin
    for user_row in
        select
            *
        from users
    loop

        select 
            * 
        into invoice_row
        from 
            invoices 
        where 
            user_id = user_row.id
            and due_date >= CURRENT_DATE
            and paid is false
        limit 1
        ;

        if not found then
            insert into invoices (user_id, due_date)
            values
            (user_row.id, CURRENT_DATE + interval '1 month');

            select 
                * 
            into invoice_row
            from 
                invoices 
            where 
                user_id = user_row.id
                and due_date >= CURRENT_DATE
                and paid is false
            limit 1
            ;

        end if;

        insert into orders (user_id, invoice_id, product_id, amount)
        select
            user_row.id
            , invoice_row.id
            , p.id
            , round(20 * random())
        from
            products as p
        ;

        select 
            sum(p.price * o.amount)
        into invoice_total
        from
            orders o
            join products p on p.id = o.product_id
        where
            invoice_id = invoice_row.id
        ;

        select
            p.month_price as price
            , s.id as signature_id
        into plan_info
        from
            signatures s
            join plans p on p.id = s.plan_id
        where
            s.user_id = user_row.id
        ;

        if not found then
            select 0 as price, null as signature_id into plan_info;
        end if;

        update invoices
        set 
            price = invoice_total + plan_info.price
            , signature_id = plan_info.signature_id
        where
            id = invoice_row.id
        ;

    end loop;
end;$$