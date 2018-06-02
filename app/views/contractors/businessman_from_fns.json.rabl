object false
node(:reg_date) { @body[:@ДатаОГРНИП].try(:to_date) }
node(:ogrn) { @body[:@ОГРН] }
node(:name) do
  attrs = @body[:СвФЛ][:ФИОРус]
  [attrs[:@Фамилия].mb_chars.capitalize, attrs[:@Имя][0] + '.', attrs[:@Отчество][0] + '.'].join(' ')
end
node(:fullname) do
  ([@body[:@НаимВидИП]] + @body[:СвФЛ][:ФИОРус].values.map { |i| i.mb_chars.capitalize }).join(' ')
end
node(:ownership) { 'ИП' }
