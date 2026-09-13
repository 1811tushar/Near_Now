'use client';
import {useMutation,useQuery,useQueryClient} from '@tanstack/react-query';
import {get,post} from '@/lib/api';
import {Card,PageHeader,Button,Skeleton,ErrorState} from '@/components/ui';
import {useToast} from '@/components/toast';

type FraudCase={id:number;orderId:number;recommendation:string;confidence:number;reasoning?:string;evidenceJson?:string;requiresHumanApproval:boolean;status:string;createdAt:string};

function evidence(value?:string){try{return value?JSON.parse(value):[]}catch{return [value||'No structured evidence available'];}}

export default function FraudReviews(){
  const qc=useQueryClient(); const {toast}=useToast();
  const q=useQuery({queryKey:['fraud-reviews'],queryFn:()=>get<FraudCase[]>('/admin/ai/fraud-reviews')});
  const m=useMutation({mutationFn:({id,clear}:{id:number;clear:boolean})=>post(`/admin/ai/fraud-reviews/${id}/resolve?clear=${clear}`),onSuccess:(_,v)=>{qc.invalidateQueries({queryKey:['fraud-reviews']});toast({title:'Review resolved',message:`Fraud case #${v.id} was updated.`,tone:'success'})}});
  if(q.isLoading)return <><PageHeader title="Fraud Review Queue" subtitle="AI-investigated orders awaiting an admin decision."/><Skeleton className="h-40"/></>;
  if(q.isError)return <ErrorState message={(q.error as Error).message} onRetry={()=>q.refetch()}/>;
  return <><PageHeader title="Fraud Review Queue" subtitle="AI-investigated orders awaiting an admin decision."/><div className="space-y-4">{(q.data||[]).map(c=><Card key={c.id} className="p-6"><div className="flex flex-wrap items-start justify-between gap-4"><div><div className="text-xs font-bold uppercase tracking-wider text-gray-500">Case #{c.id} · Order #{c.orderId}</div><div className="mt-2 inline-flex rounded-full bg-mint px-3 py-1 text-xs font-bold uppercase">Recommendation: {c.recommendation}</div><div className="mt-1 text-xs text-gray-500">Confidence: {(c.confidence*100).toFixed(0)}% · {c.status}</div></div><div className="flex gap-2"><Button disabled={m.isPending} onClick={()=>m.mutate({id:c.id,clear:true})}>Clear</Button><button disabled={m.isPending} onClick={()=>m.mutate({id:c.id,clear:false})} className="rounded-xl border border-red-200 px-4 py-2.5 text-sm font-semibold text-red-700">Keep blocked</button></div></div><p className="mt-5 text-sm leading-6 text-gray-700">{c.reasoning||'No reasoning recorded.'}</p><div className="mt-4"><div className="text-sm font-bold">Evidence</div><ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-gray-600">{evidence(c.evidenceJson).map((e:any,i:number)=><li key={i}>{typeof e==='string'?e:JSON.stringify(e)}</li>)}</ul></div></Card>)}{!q.data?.length&&<Card className="p-10 text-center text-sm text-gray-500">No pending fraud reviews.</Card>}</div></>;
}
